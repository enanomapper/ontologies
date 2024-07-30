#!/bin/bash
# Patterns to look for in the .iris files
opt="^[+,-]"                   # Add-remove pattern
descendant="D"                # Descendant pattern
sc="(?<=:)\s*http[^\s]+"    # Subclass pattern
spc="http:.+(?=\):)"          # Superclass pattern
comment="(?<=\s).+"           # Comment pattern

# Remove 
echo Removing files
rm external-dev/term-files/add/*
rm external-dev/term-files/remove/*
rm external-dev/templates/*subclass_assertion.csv


# List of ontologies
ontologies=("fabio" "aopo" "obi" "bfo" "ccont" "pato" "cheminf" "sio" "chmo" "npo" 
            "uo" "bao" "ncit" "uberon" "chebi" "oae" "envo" "go" "efo" "obcs" "bto" 
            "cito" "clo" "iao" "ro" "msio")

# Process each ontology
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
    > "$tmp_add_with_descendants"
    > "$tmp_add_without_descendants"
    > "$tmp_remove_with_descendants"
    > "$tmp_remove_without_descendants"
    > "$tmp_subclass_assertion"

    # Output ROBOT template headers
    echo "IRI,subClassOf" > "$tmp_subclass_assertion"
    echo "ID,SC %" >> "$tmp_subclass_assertion"

    while IFS= read -r line; do
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
    wget -nc -O external-dev/tmp/source/${ONTO}.owl $(grep "owl=" config/${ONTO}.props | cut -d'=' -f2)
    # Case
    add_D=external-dev/term-files/add/${ONTO}_add_D.txt
    add=external-dev/term-files/add/${ONTO}_add.txt
    remove=external-dev/term-files/remove/${ONTO}_remove.txt
    remove_D=external-dev/term-files/remove/${ONTO}_remove_D.txt
    file_status="$([[ -f $add ]] && echo 1 || echo 0)$( [[ -f $add_D ]] && echo 1 || echo 0)$( [[ -f $remove ]] && echo 1 || echo 0)$( [[ -f $remove_D ]] && echo 1 || echo 0)"
    case $file_status in
        1111)
            echo Settings: add, add_D, remove, and remove_D all existing
            echo 1111
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add_D \
                    --select "annotations self descendants" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot \
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
            echo 1110
            echo Settings: add, add_D, and remove existing but no remove_D
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add_D \
                    --select "annotations self descendants" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot \
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
            echo Settings: add, add_D, and remove_D existing but no remove
            echo 1101
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add_D \
                    --select "annotations self descendants" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot \
                merge \
                    --input external-dev/tmp/${ONTO}_add_D.owl \
                    --input external-dev/tmp/${ONTO}_add.owl \
                remove \
                    --term-file $remove_D \
                    --select "self descendants" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1100)
            echo Settings: add and add_D existing but no remove or remove_D
            echo 1100
            bash robot \
                filter \
                    --input external-dev/tmp/source/${ONTO}.owl \
                    --term-file $add_D \
                    --select "annotations self descendants" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl
            bash robot \
                filter \
                    --input external-dev/tmp/source/${ONTO}.owl \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                merge \
                    --input external-dev/tmp/${ONTO}_add_D.owl \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1011)
            echo Settings: add, remove, and remove_D existing but no add_D
            echo 1011
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot \
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
            echo 1010
            echo Settings: add and remove existing but no add_D or remove_D
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot \
                remove \
                    --input external-dev/tmp/${ONTO}_add.owl \
                    --term-file $remove \
                    --select "self" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1001)
            echo 1001
            echo Settings: add and remove_D existing but no add_D or remove
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add.owl    
            bash robot \
                remove \
                    --input external-dev/tmp/${ONTO}_add.owl   \
                    --term-file $remove_D \
                    --select "self descendants" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        1000)
            echo 1000
            echo Settings: only add existing
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add \
                    --select "annotations self" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl    
            ;;
        0111)
            echo 0111
            echo Settings: add_D, remove, and remove_D existing but no add
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add_D \
                    --select "annotations self descendants" \
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
            echo 0110
            echo Settings: add_D and remove existing but no add or remove_D
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add_D \
                    --select "annotations self descendants" \
                    --signature false \
                remove \
                    --term-file $remove \
                    --select "self" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        0101)
            echo 0101
            echo Settings: add_D and remove_D existing but no add or remove
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add_D \
                    --select "annotations self descendants" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_add_D.owl \
                remove \
                    --term-file $remove_D \
                    --select "self descendants" \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
        0100)
            echo 0100
            echo Settings: only add_D existing
            bash robot \
                merge \
                    --input external-dev/tmp/source/${ONTO}.owl \
                filter \
                    --term-file $add_D \
                    --select "annotations self descendants" \
                    --signature false \
                    --output external-dev/tmp/${ONTO}_no_spcs.owl
            ;;
    esac
    # Template subclassOf assertions
    if [[ -f "external-dev/templates/${ONTO}_subclass_assertion.csv" ]]; then
        bash robot \
            template \
                --template "external-dev/templates/${ONTO}_subclass_assertion.csv" \
                --output external-dev/tmp/${ONTO}_spcs.owl
        bash robot \
            merge \
                --include-annotations true \
                --input external-dev/tmp/${ONTO}_no_spcs.owl \
                --input external-dev/tmp/${ONTO}_spcs.owl \
                --output external-dev/${ONTO}-ext.owl

    else
        cp external-dev/tmp/${ONTO}_no_spcs.owl external-dev/${ONTO}-ext.owl
    fi
done

#rm -r external-dev/tmp