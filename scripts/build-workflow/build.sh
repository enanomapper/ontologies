#!/bin/bash

# -------------------- Configuration Variables ------------------------
ROBOT_VERSION="1.9.6"
ROBOT_JAR="robot.jar"
ROBOT_BIN="robot"
ROBOT_URL="https://github.com/ontodev/robot"

# Directory structure
BASE_DIR="$(pwd)"
CONFIG_DIR="${BASE_DIR}/config"
EXTERNAL_DEV_DIR="${BASE_DIR}/external-dev"
TEMPLATE_DIR="${CONFIG_DIR}/templates"
TERM_FILES_DIR="${EXTERNAL_DEV_DIR}/term-files"
TMP_DIR="${EXTERNAL_DEV_DIR}/tmp"
SOURCE_DIR="${TMP_DIR}/source"

# File paths
PREFIXES_FILE="${EXTERNAL_DEV_DIR}/prefixes.json"
CHEMICAL_COMP_TEMPLATE="${TEMPLATE_DIR}/predicates/chemical_compositions.tsv"

# Regex patterns
PATTERN_OPT="^[+,-]"                 # Add-remove pattern
PATTERN_DESCENDANT="D"               # Descendant pattern
PATTERN_SC="(?<=:)\s*http[^\s]+"     # Subclass pattern
PATTERN_SPC="http:.+(?=\):)"         # Superclass pattern
PATTERN_COMMENT="(?<=\s).+"          # Comment pattern

# -------------------- Function Definitions --------------------------

# Function to create necessary directories
setup_directories() {
    mkdir -p "${TERM_FILES_DIR}/add"
    mkdir -p "${TERM_FILES_DIR}/remove"
    mkdir -p "${TEMPLATE_DIR}"
    mkdir -p "${TMP_DIR}"
    mkdir -p "${SOURCE_DIR}"
}

# Function to download ROBOT if not present
download_robot() {
    if [ ! -f "${ROBOT_BIN}" ] || [ ! -f "${ROBOT_JAR}" ]; then
        echo "Downloading ROBOT..."
        wget -nc "${ROBOT_URL}/raw/master/bin/robot"
        wget -nc "${ROBOT_URL}/releases/download/v${ROBOT_VERSION}/${ROBOT_JAR}"
        chmod +x "${ROBOT_BIN}"
    fi
}

# Function to replace full URIs with namespace prefixes
replace_namespaces() {
    local input_file="$1"
    local temp_file=$(mktemp)

    # Declare an associative array with the namespaces
    declare -A namespaces=(
        ["http://www.bioassayontology.org/bao#"]="bao"
        ["http://purl.bioontology.org/ontology/npo#"]="npo"
        ["http://semanticscience.org/resource/"]="sio"
        ["http://purl.org/spar/fabio/"]="fabio"
        ["http://semanticscience.org/resource/"]="cheminf"
        ["http://livercancer.imbi.uni-heidelberg.de/ccont#"]="ccont"
        ["http://purl.enanomapper.org/onto/"]="enm"
        ["http://purl.obolibrary.org/obo/"]="obo"
        ["http://aopkb.org/aop_ontology#"]="aopo"
        ["http://www.ebi.ac.uk/efo/"]="efo"
    )

    # Create a sed expression to replace namespaces with CURIEs
    sed_expr=""
    for url in "${!namespaces[@]}"; do
        prefix="${namespaces[$url]}"
        sed_expr+="s|${url}|${prefix}:|g;"
    done

    # Use sed to perform the replacements
    sed "$sed_expr" "$input_file" > "$temp_file"

    # Replace the original file with the modified content
    mv "$temp_file" "$input_file"
}

# Function to process iris config files and generate term files (replaces Slimmer)
process_config_file() {
    local onto="$1"
    echo "Processing config file for ${onto}"
    
    # Initialize temporary files
    local tmp_add_with_descendants="${TERM_FILES_DIR}/add/${onto}_add_D.txt.tmp"
    local tmp_add_without_descendants="${TERM_FILES_DIR}/add/${onto}_add.txt.tmp"
    local tmp_remove_with_descendants="${TERM_FILES_DIR}/remove/${onto}_remove_D.txt.tmp"
    local tmp_remove_without_descendants="${TERM_FILES_DIR}/remove/${onto}_remove.txt.tmp"
    local tmp_subclass_assertion="${TEMPLATE_DIR}/${onto}_subclass_assertion.csv.tmp"
    local sc_file="${TEMPLATE_DIR}/${onto}_subclass_assertion.csv"

    # Ensure the temporary files are empty at the start
    > "$tmp_add_with_descendants"
    > "$tmp_add_without_descendants"
    > "$tmp_remove_with_descendants"
    > "$tmp_remove_without_descendants"
    > "$tmp_subclass_assertion"

    # Initialize the SC flag
    local SC=false
    
    while IFS= read -r line || [[ -n $line ]]; do
        local add_sc=$(echo "$line" | grep -Po "$PATTERN_SC")
        local add_spc=$(echo "$line" | grep -Po "$PATTERN_SPC")
        local add_comment=$(echo "$line" | grep -Po "$PATTERN_COMMENT")
        local add_opt=$(echo "$line" | grep -Po "$PATTERN_OPT")
        local add_d=$(echo "$line" | grep -Po "$PATTERN_DESCENDANT")
        
        if [[ -z $add_d ]]; then 
            add_d="no"
        else 
            add_d="$PATTERN_DESCENDANT"
        fi
        
        # Add term
        if [[ $add_opt == *"+"* && -n $add_sc ]]; then
            # Add with/without descendants
            if [[ $add_d == "$PATTERN_DESCENDANT" ]]; then
                echo "${add_sc} # ${add_comment}" >> "$tmp_add_with_descendants"
            else
                echo "${add_sc} # ${add_comment}" >> "$tmp_add_without_descendants"
            fi

            # Fill up template with new subclass assertion
            if [[ -n $add_spc ]]; then
                SC=true
                echo "${add_sc},${add_spc}" >> "$tmp_subclass_assertion"
            fi
        fi
        
        # Remove term
        if [[ $add_opt == *"-"* && -n $add_sc ]]; then
            # Remove with/without descendants
            if [[ $add_d == "$PATTERN_DESCENDANT" ]]; then
                echo "${add_sc} # ${add_comment}" >> "$tmp_remove_with_descendants"
            else
                echo "${add_sc} # ${add_comment}" >> "$tmp_remove_without_descendants"
            fi
        fi
    done < "${CONFIG_DIR}/${onto}.iris"
    
    # Move or remove files if they are not empty
    for file in "$tmp_add_with_descendants" "$tmp_add_without_descendants" "$tmp_remove_with_descendants" "$tmp_remove_without_descendants" "$tmp_subclass_assertion"; do
        if [[ -s $file ]]; then
            replace_namespaces "$file"
            mv "$file" "${file%.tmp}"
        else
            rm "$file"
        fi
    done
    
    # Process subclass assertion file if needed
    if [[ $SC == true ]]; then
        sort -r "$sc_file" | uniq > "tmp_sc"
        mv "tmp_sc" "$sc_file"
        # Output ROBOT template headers
        echo "ID,SC %" | cat - "$sc_file" > temp && mv temp "$sc_file"
        echo "IRI,subClassOf" | cat - "$sc_file" > temp && mv temp "$sc_file"
    elif [[ -f "$sc_file" ]]; then
        rm "$sc_file"
    fi
}

# Function to download ontology source
download_ontology_source() {
    local onto="$1"
    local source_file="${SOURCE_DIR}/${onto}.owl"
    
    if [ ! -f "$source_file" ]; then
        echo "Downloading ontology source for ${onto}..."
        local owl_url=$(grep "owl=" "${CONFIG_DIR}/${onto}.props" | cut -d'=' -f2)
        wget -nc -O "$source_file" "$owl_url"
        
        # Special case for NPO ontology
        if [[ "$onto" == "npo" ]]; then
            echo "Reasoning NPO (hermit)"
            bash "$ROBOT_BIN" --prefixes "$PREFIXES_FILE" \
                reason --reasoner hermit --annotate-inferred-axioms true \
                --input "$source_file" --output "$source_file"
        fi
    fi
}

# Function to process term files with ROBOT
process_ontology() {
    local onto="$1"
    echo -e "\n>[${onto}]"
    
    # Define paths for term files
    local add_D="${TERM_FILES_DIR}/add/${onto}_add_D.txt"
    local add="${TERM_FILES_DIR}/add/${onto}_add.txt"
    local remove="${TERM_FILES_DIR}/remove/${onto}_remove.txt"
    local remove_D="${TERM_FILES_DIR}/remove/${onto}_remove_D.txt"
    
    # Check which files exist
    local file_status="$([[ -f $add ]] && echo 1 || echo 0)$([[ -f $add_D ]] && echo 1 || echo 0)$([[ -f $remove ]] && echo 1 || echo 0)$([[ -f $remove_D ]] && echo 1 || echo 0)"
    
    # Process based on which files exist
    echo "[${onto}] Settings: $(echo $file_status | sed 's/1111/add, add_D, remove, and remove_D all existing/;s/1110/add, add_D, and remove existing but no remove_D/;s/1101/add, add_D, and remove_D existing but no remove/;s/1100/add and add_D existing but no remove or remove_D/;s/1011/add, remove, and remove_D existing but no add_D/;s/1010/add and remove existing but no add_D or remove_D/;s/1001/add and remove_D existing but no add_D or remove/;s/1000/only add existing/;s/0111/add_D, remove, and remove_D existing but no add/;s/0110/add_D and remove existing but no add or remove_D/;s/0101/add_D and remove_D existing but no add or remove/;s/0100/only add_D existing/')"
    
    # Create common ROBOT command prefix
    local robot_cmd="bash $ROBOT_BIN --prefixes $PREFIXES_FILE"
    
    # Process add_D if it exists
    if [[ -f $add_D ]]; then
        $robot_cmd merge --input "${SOURCE_DIR}/${onto}.owl" \
            filter --trim true --preserve-structure false --axioms all \
            --term-file "$add_D" --select "annotations self descendants" \
            --signature false --output "${TMP_DIR}/${onto}_add_D.owl"
    fi
    
    # Process add if it exists
    if [[ -f $add ]]; then
        $robot_cmd merge --input "${SOURCE_DIR}/${onto}.owl" \
            filter --trim true --preserve-structure false --axioms all \
            --term-file "$add" --select "annotations self" \
            --signature false --output "${TMP_DIR}/${onto}_add.owl"
    fi
    
    # Merge add files if both exist
    if [[ -f "${TMP_DIR}/${onto}_add_D.owl" && -f "${TMP_DIR}/${onto}_add.owl" ]]; then
        $robot_cmd merge --input "${TMP_DIR}/${onto}_add_D.owl" \
            --input "${TMP_DIR}/${onto}_add.owl" --include-annotations true \
            --output "${TMP_DIR}/${onto}_merged.owl"
    elif [[ -f "${TMP_DIR}/${onto}_add_D.owl" ]]; then
        cp "${TMP_DIR}/${onto}_add_D.owl" "${TMP_DIR}/${onto}_merged.owl"
    elif [[ -f "${TMP_DIR}/${onto}_add.owl" ]]; then
        cp "${TMP_DIR}/${onto}_add.owl" "${TMP_DIR}/${onto}_merged.owl"
    fi
    
    # Process removals if they exist
    if [[ -f "${TMP_DIR}/${onto}_merged.owl" ]]; then
        if [[ -f $remove_D ]]; then
            $robot_cmd remove --input "${TMP_DIR}/${onto}_merged.owl" \
                --term-file "$remove_D" --select "self descendants annotations" \
                --output "${TMP_DIR}/${onto}_temp.owl"
            mv "${TMP_DIR}/${onto}_temp.owl" "${TMP_DIR}/${onto}_merged.owl"
        fi
        
        if [[ -f $remove ]]; then
            $robot_cmd remove --input "${TMP_DIR}/${onto}_merged.owl" \
                --term-file "$remove" --select "self annotations" \
                --output "${TMP_DIR}/${onto}_temp.owl"
            mv "${TMP_DIR}/${onto}_temp.owl" "${TMP_DIR}/${onto}_merged.owl"
        fi
        
        mv "${TMP_DIR}/${onto}_merged.owl" "${TMP_DIR}/${onto}_no_spcs.owl"
    else
        # Handle edge case - only remove files exist
        if [[ -f $remove_D || -f $remove ]]; then
            echo "Warning: Only remove files exist for ${onto}, but no add files. This may not work as expected."
            
            # Start with the source ontology
            cp "${SOURCE_DIR}/${onto}.owl" "${TMP_DIR}/${onto}_no_spcs.owl"
            
            # Apply removals
            if [[ -f $remove_D ]]; then
                $robot_cmd remove --input "${TMP_DIR}/${onto}_no_spcs.owl" \
                    --term-file "$remove_D" --select "self descendants annotations" \
                    --output "${TMP_DIR}/${onto}_temp.owl"
                mv "${TMP_DIR}/${onto}_temp.owl" "${TMP_DIR}/${onto}_no_spcs.owl"
            fi
            
            if [[ -f $remove ]]; then
                $robot_cmd remove --input "${TMP_DIR}/${onto}_no_spcs.owl" \
                    --term-file "$remove" --select "self annotations" \
                    --output "${TMP_DIR}/${onto}_temp.owl"
                mv "${TMP_DIR}/${onto}_temp.owl" "${TMP_DIR}/${onto}_no_spcs.owl"
            fi
        else
            echo "Error: No term files found for ${onto}"
            return 1
        fi
    fi
    
    echo "...Done filtering source ontology ${onto}"
}

# Function to apply templates and annotations
finalize_ontology() {
    local onto="$1"
    local timestamp=$(date -I)
    local output_file="${EXTERNAL_DEV_DIR}/${onto}-slim.owl"
    local sc_template="${TEMPLATE_DIR}/${onto}_subclass_assertion.csv"
    
    # Apply subclass assertions template if it exists
    if [[ -f "$sc_template" ]]; then
        echo "Injecting SC via template for ${onto}"
        $robot_cmd template --template "$sc_template" \
            --output "${TMP_DIR}/${onto}_spcs.owl"
        
        # Merge template with filtered ontology
        $robot_cmd merge --include-annotations true \
            --input "${TMP_DIR}/${onto}_no_spcs.owl" \
            --input "${TMP_DIR}/${onto}_spcs.owl" \
            --output "$output_file"
    else
        cp "${TMP_DIR}/${onto}_no_spcs.owl" "$output_file"
    fi
    
    # Add annotations and filter
    $robot_cmd annotate --input "$output_file" \
        --ontology-iri "http://purl.enanomapper.net/onto/external/${onto}-slim.owl" \
        --version-iri "https://purl.enanomapper.org/onto/external-dev/${onto}-slim-prop.owl/" \
        --annotation http://www.w3.org/2002/07/owl#versionInfo "This ontology subset was generated automatically with ROBOT (http://robot.obolibrary.org)" \
        --annotation http://www.geneontology.org/formats/oboInOwl#date "$timestamp (yyyy-mm-dd)" \
        filter --prefixes "$PREFIXES_FILE" --select "rdfs:subClassOf=obo:BFO_0000001 annotations self" --trim true --signature true \
        reduce --reasoner hermit --output "$output_file"
    
    # Extract object and data properties if term file exists
    if [[ -f "${CONFIG_DIR}/${onto}-term-file.txt" ]]; then
        echo "Extracting object and data properties for ${onto}"
        $robot_cmd extract --method subset \
            --input "${SOURCE_DIR}/${onto}.owl" \
            --term-file "${CONFIG_DIR}/${onto}-term-file.txt" \
            annotate --version-iri "https://purl.enanomapper.org/onto/external-dev/${onto}-slim-prop.owl/" \
            --ontology-iri "https://purl.enanomapper.org/onto/external-dev/${onto}-slim.owl/" \
            --output "${EXTERNAL_DEV_DIR}/${onto}-slim-prop.owl"
    fi
}

# Function to process chemical compositions
process_chemical_compositions() {
    echo "Processing chemical compositions..."
    $robot_cmd merge --input "${BASE_DIR}/enanomapper-dev.owl" \
        template --template "$CHEMICAL_COMP_TEMPLATE" \
        --ontology-iri "https://purl.enanomapper.org/onto/chemical_compositions.owl" \
        --output "${EXTERNAL_DEV_DIR}/chemical_compositions.owl"
}

# Function to perform full ontology processing
process_all_ontologies() {
    local ontologies=("$@")
    
    for onto in "${ontologies[@]}"; do
        # Process the configuration file
        process_config_file "$onto"
        
        # Download ontology source
        download_ontology_source "$onto"
        
        # Process with ROBOT
        process_ontology "$onto"
        
        # Finalize and annotate
        finalize_ontology "$onto"
    done
}

# -------------------- Main Script Execution -------------------------

# Check if an ontology parameter was provided
if [ $# -eq 1 ]; then
    # Process only the specified ontology
    ontologies=("$1")
    echo "Processing single ontology: $1"
else
    # List of all ontologies (original behavior)
    ontologies=("fabio" "aopo" "obi" "bfo" "ccont" "pato" "cheminf" "sio" "chmo" "npo" 
                "uo" "bao" "ncit" "uberon" "chebi" "oae" "envo" "go" "efo" "obcs" "bto" 
                "cito" "clo" "iao" "ro" "msio")
    echo "Processing all ontologies"
fi

# Setup necessary directories
setup_directories

# Download ROBOT
download_robot

# Set robot command alias for convenience
robot_cmd="bash $ROBOT_BIN --prefixes $PREFIXES_FILE"

# Process all ontologies
process_all_ontologies "${ontologies[@]}"

# Process chemical compositions template
process_chemical_compositions

# Clean up
echo "Done processing ontologies"
echo "Removing temporary .iris files"
rm -f *.iris

echo "Process completed successfully"
