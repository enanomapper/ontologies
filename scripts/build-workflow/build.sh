#!/bin/bash

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

wget -nc https://github.com/ontodev/robot/raw/master/bin/robot
wget -nc https://github.com/ontodev/robot/releases/download/v1.9.6/robot.jar
# Patterns to look for in the .iris files
opt="^[+,-]"                   # Add-remove pattern
descendant="D"                # Descendant pattern
sc="(?<=:)\s*http[^\s]+"    # Subclass pattern
spc="http:.+(?=\):)"          # Superclass pattern
comment="(?<=\s).+"           # Comment pattern

# Namespace-curie function
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

# Remove 
#echo Removing files
#rm external-dev/term-files/add/* # Managed in slimmer config files
#rm external-dev/term-files/remove/* # Managed in slimmer config files
#rm external-dev/templates/*subclass_assertion.csv

# Process each ontology
for ONTO in "${ontologies[@]}"; do
    SC=False
    echo Processing config file for $ONTO 
    # Initialize temporary files
    tmp_add_with_descendants="external-dev/term-files/add/${ONTO}_add_D.txt.tmp"
    tmp_add_without_descendants="external-dev/term-files/add/${ONTO}_add.txt.tmp"
    tmp_remove_with_descendants="external-dev/term-files/remove/${ONTO}_remove_D.txt.tmp"
    tmp_remove_without_descendants="external-dev/term-files/remove/${ONTO}_remove.txt.tmp"
    tmp_subclass_assertion="external-dev/templates/${ONTO}_subclass_assertion.csv.tmp"

    # Ensure the temporary files are empty at the start
    mkdir -p "external-dev/term-files/add"
    mkdir -p "external-dev/term-files/remove"
    mkdir -p "external-dev/templates"

     > "$tmp_add_with_descendants"
     > "$tmp_add_without_descendants"
     > "$tmp_remove_with_descendants"
     > "$tmp_remove_without_descendants"
     > "$tmp_subclass_assertion"

    # Initialize the SC flag
    SC=False
    while IFS= read -r line || [[ -n $line ]]; do
        add_sc=$(echo "$line" | grep -Po "$sc")
        add_spc=$(echo "$line" | grep -Po "$spc")
        add_comment=$(echo "$line" | grep -Po "$comment")
        add_opt=$(echo "$line" | grep -Po "$opt")
        add_d=$(echo "$line" | grep -Po "$descendant")
        if [[ -z $add_d ]]; then 
            add_d="no"
        else 
            add_d="$descendant"
        fi
        # Add term
        if [[ $add_opt == *"+"* ]]; then
            # Add with descendants
            if [[ $add_d == "$descendant" && -n $add_sc ]]; then
                echo "${add_sc} # ${add_comment}" >> "$tmp_add_with_descendants"
            elif [[ $add_d != "$descendant" && -n $add_sc ]]; then
                # Add without descendants
                echo "${add_sc} # ${add_comment}" >> "$tmp_add_without_descendants"
            fi

            # Fill up template with new SC % assertion
            if [[ -n $add_spc && -n $add_sc ]]; then
                SC=True
                echo "${add_sc},${add_spc}" >> "$tmp_subclass_assertion"
            fi
        fi
        # Remove term
        if [[ $add_opt == *"-"* ]]; then
            # Remove with descendants
            if [[ $add_d == "$descendant" && -n $add_sc  ]]; then
                echo "${add_sc} # ${add_comment}" >> "$tmp_remove_with_descendants"
            elif [[ $add_d != "$descendant" && -n $add_sc  ]]; then
                echo "${add_sc} # ${add_comment}" >> "$tmp_remove_without_descendants"
            fi
        fi
    done < "config/${ONTO}.iris"
    # Move or remove files if they are not empty
    for file in "$tmp_add_with_descendants" "$tmp_add_without_descendants" "$tmp_remove_with_descendants" "$tmp_remove_without_descendants" "$tmp_subclass_assertion" ; do
        if [[ -s $file ]]; then
            replace_namespaces $file
            mv "$file" "${file%.tmp}"
        else
            rm "$file"
        fi
    done
    if [[ $SC == False ]]; then
        rm external-dev/templates/${ONTO}_subclass_assertion.csv
    else
        sort -r external-dev/templates/${ONTO}_subclass_assertion.csv | uniq > tmp_sc
        rm external-dev/templates/${ONTO}_subclass_assertion.csv
        mv tmp_sc external-dev/templates/${ONTO}_subclass_assertion.csv
        # Output ROBOT template headers
        echo "ID,SC %" | cat - "external-dev/templates/${ONTO}_subclass_assertion.csv" > temp && mv temp "external-dev/templates/${ONTO}_subclass_assertion.csv"
        echo "IRI,subClassOf" | cat - "external-dev/templates/${ONTO}_subclass_assertion.csv" > temp && mv temp "external-dev/templates/${ONTO}_subclass_assertion.csv"
    fi
done


# Clean up downloaded .iris files
echo Done processing config files
echo Removing iris files
rm *.iris

#### ROBOT
echo ROBOT processing of term files
mkdir external-dev/tmp
mkdir external-dev/tmp/source

for ONTO in "${ontologies[@]}"; do
    echo ____________________________________________[${ONTO}]____________________________________________
    wget -nc -O external-dev/tmp/source/${ONTO}.owl $(grep "owl=" config/${ONTO}.props | cut -d'=' -f2)
    if [[ "$ONTO" == "npo" ]]; then
    echo "Reasoning NPO (ELK)"
        bash robot --prefixes "external-dev/prefixes.json" \
            reason --reasoner ELK --annotate-inferred-axioms true \
            --input external-dev/tmp/source/${ONTO}.owl --output external-dev/tmp/source/${ONTO}.owl
    fi
    # Case
    add_D=external-dev/term-files/add/${ONTO}_add_D.txt
    add=external-dev/term-files/add/${ONTO}_add.txt
    remove=external-dev/term-files/remove/${ONTO}_remove.txt
    remove_D=external-dev/term-files/remove/${ONTO}_remove_D.txt
    file_status="$([[ -f $add ]] && echo 1 || echo 0)$( [[ -f $add_D ]] && echo 1 || echo 0)$( [[ -f $remove ]] && echo 1 || echo 0)$( [[ -f $remove_D ]] && echo 1 || echo 0)"
   
    case $file_status in
        1111)
            echo "[${ONTO}] Settings: add, add_D, remove, and remove_D all existing"
            
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add_D \
                    --select "annotations self descendants parents" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/${ONTO}_add_D.owl \
                    --input external-dev/tmp/${ONTO}_add.owl \
                    --include-annotations true \
                remove \
                    --term-file $remove_D \
                    --select "self descendants" \
                remove \
                    --term-file $remove \
                    --select "self" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1110)
            
            echo "[${ONTO}] Settings: add, add_D, and remove existing but no remove_D"
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add_D \
                    --select "annotations self descendants parents" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/${ONTO}_add_D.owl \
                    --input external-dev/tmp/${ONTO}_add.owl \
                    --include-annotations true \
                remove \
                    --term-file $remove \
                    --select "self" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1101)
            echo "[${ONTO}] Settings: add, add_D, and remove_D existing but no remove"
            
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add_D \
                    --select "annotations self descendants parents" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/${ONTO}_add_D.owl \
                    --input external-dev/tmp/${ONTO}_add.owl \
                remove \
                    --term-file $remove_D \
                    --select "self descendants" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1100)
            echo "[${ONTO}] Settings: add and add_D existing but no remove or remove_D"
            
            bash robot --prefixes "external-dev/prefixes.json" \
                filter \
                    --trim true \
                    --axioms all \
                    --input external-dev/tmp/source/${ONTO}.owl \
                    --term-file $add_D \
                    --select "annotations self descendants parents" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl
            bash robot --prefixes "external-dev/prefixes.json" \
                filter \
                    --trim true \
                    --axioms all \
                    --input external-dev/tmp/source/${ONTO}.owl \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                merge \
                    --input external-dev/tmp/${ONTO}_add_D.owl \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1011)
            echo "[${ONTO}] Settings: add, remove, and remove_D existing but no add_D"
            
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/${ONTO}_add_D.owl \
                    --input external-dev/tmp/${ONTO}_add.owl \
                remove \
                    --term-file $remove_D \
                    --select "self descendants" \
                remove \
                    --term-file $remove \
                    --select "self" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1010)
            
            echo "[${ONTO}] Settings: add and remove existing but no add_D or remove_D"
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot --prefixes "external-dev/prefixes.json" \
                remove \
                    --input external-dev/tmp/${ONTO}_add.owl \
                    --term-file $remove \
                    --select "self" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1001)
            
            echo "[${ONTO}] Settings: add and remove_D existing but no add_D or remove"
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot --prefixes "external-dev/prefixes.json" \
                remove \
                    --input external-dev/tmp/${ONTO}_add.owl   \
                    --term-file $remove_D \
                    --select "self descendants" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1000)
            
            echo "[${ONTO}] Settings: only add existing"
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl    
            ;;
        0111)
            
            echo "[${ONTO}] Settings: add_D, remove, and remove_D existing but no add"
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add_D \
                    --select "annotations self descendants parents" \
                    --signature false \
                remove \
                    --term-file $remove_D \
                    --select "self descendants" \
                remove \
                    --term-file $remove \
                    --select "self" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        0110)
            
            echo "[${ONTO}] Settings: add_D and remove existing but no add or remove_D"
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add_D \
                    --select "annotations self descendants parents" \
                    --signature false \
                remove \
                    --term-file $remove \
                    --select "self" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        0101)
            
            echo "[${ONTO}] Settings: add_D and remove_D existing but no add or remove"
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add_D \
                    --select "annotations self descendants parents" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl \
                remove \
                    --term-file $remove_D \
                    --select "self descendants" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        0100)
            
            echo "[${ONTO}] Settings: only add_D existing"
            bash robot --prefixes "external-dev/prefixes.json" \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --trim true \
                    --axioms all \
                    --term-file $add_D \
                    --select "annotations self descendants parents" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
    esac
    echo ...Done filtering source ontology ${ONTO}
    # Template subclassOf assertions
    timestamp=$(date -I)
    if [[ -f "external-dev/templates/${ONTO}_subclass_assertion.csv" ]]; then
        echo Inject SC via template. 
        bash robot --prefixes "external-dev/prefixes.json" \
            template \
                --template "external-dev/templates/${ONTO}_subclass_assertion.csv" \
                --output external-dev/tmp/${ONTO}_spcs.owl
        bash robot --prefixes "external-dev/prefixes.json" \
            merge \
                --include-annotations true \
                --input external-dev/tmp/${ONTO}_no_spcs.owl \
                --input external-dev/tmp/${ONTO}_spcs.owl \
                --output external-dev/${ONTO}-slim.owl \
            annotate \
                --ontology-iri "http://purl.enanomapper.net/onto/external/${ONTO}-slim.owl" \
                --version-iri "https://purl.enanomapper.org/onto/external-dev/${ONTO}-slim-prop.owl/"\
                --annotation http://www.w3.org/2002/07/owl#versionInfo "This ontology subset was generated automatically with ROBOT (http://robot.obolibrary.org)" \
                --annotation http://www.geneontology.org/formats/oboInOwl#date "$timestamp (yyy-mm-dd)"     

    else
        cp external-dev/tmp/${ONTO}_no_spcs.owl external-dev/${ONTO}-slim.owl
    fi
    
    # Add props, if exist
    if [[ -f "config/${ONTO}-term-file.txt" ]]; then 
        echo Extracting object and data properties
        bash robot --prefixes "external-dev/prefixes.json" \
            extract \
                --method subset --input  external-dev/tmp/source/${ONTO}.owl \
                --term-file config/${ONTO}-term-file.txt \
            annotate --version-iri "https://purl.enanomapper.org/onto/external-dev/${ONTO}-slim-prop.owl/"\
                    --ontology-iri "https://purl.enanomapper.org/onto/external-dev/${ONTO}-slim.owl/" \
                --output external-dev/${ONTO}-slim-prop.owl \

    fi

done

# Add predicates from templates

#rm -r external-dev/tmp

bash robot merge --input enanomapper-dev.owl template --template external-dev/templates/predicates/chemical_compositions.tsv \
  --ontology-iri "https://purl.enanomapper.org/onto/chemical_compositions.owl" \
  --output external-dev/chemical_compositions.owl