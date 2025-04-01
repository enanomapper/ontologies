#!/bin/bash

# Patterns to look for in the .iris files
opt="[+,-]"                   # Add-remove pattern
descendant="D"                # Descendant pattern
sc="(?<=:)http:.+?(?=\s.)"    # Subclass pattern
spc="http:.+(?=\):)"          # Superclass pattern
comment="(?<=\s).+"           # Comment pattern

# Output CSV headers
echo "IRI,subClassOf" > external-dev/subclass_asssertion.csv
echo "IRI,SC %" >> external-dev/subclass_asssertion.csv

# Create directories for term lists
mkdir -p "external-dev/term-files/add/"
mkdir -p "external-dev/term-files/remove/"

# List of ontologies
ontologies=("fabio" "aopo" "obi" "bfo" "ccont" "pato" "cheminf" "sio" "chmo" "npo" 
            "uo" "bao" "ncit" "uberon" "chebi" "oae" "envo" "go" "efo" "obcs" "bto" 
            "cito" "clo" "iao" "ro")

# Process each ontology
for ONTO in "${ontologies[@]}"; do

    wget -nc -q "https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.iris"

    while IFS= read -r line; do
        add_sc=$(echo $line | grep -Po "$sc")
        add_spc=$(echo $line | grep -Po "$spc")
        add_comment=$(echo $line | grep -Po "$comment")
        add_opt=$(echo $line | grep -Po "$opt")
        add_d=$(echo $line | grep -Po "$descendant")
        if [[ -z $add_d ]]; then 
            add_d="no"
        else 
            add_d="$descendant"
        fi

        # Add term
        if [[ $add_opt == *"+"* ]]; then
            # Add with descendants
            if [[ $add_d == "$descendant" ]]; then
                echo "${add_sc} # ${add_comment}" >> "external-dev/term-files/add/${ONTO}_add_D.txt"
            else
                # Add without descendants
                echo "${add_sc} # ${add_comment}" >> "external-dev/term-files/add/${ONTO}_add.txt"
            fi
        fi

        # Remove term
        if [[ $add_opt == *"-"* ]]; then
            # Remove with descendants
            if [[ $add_d == "$descendant" ]]; then
                echo "${add_sc} # ${add_comment}" >> "external-dev/term-files/remove/${ONTO}_remove_D.txt"
            else
                echo "${add_sc} # ${add_comment}" >> "external-dev/term-files/remove/${ONTO}_remove.txt"
            fi
        fi

        # Fill up template with new SC % assertion
        if [[ -n $add_spc ]]; then
            echo "${add_sc},${add_spc}" >> external-dev/subclass_asssertion.csv
        fi
    done < "${ONTO}.iris"
done

# Clean up downloaded .iris files
rm *.iris
