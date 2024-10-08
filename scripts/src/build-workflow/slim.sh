#!/bin/bash

# Download ROBOT files if they don't exist
wget -nc https://github.com/ontodev/robot/raw/master/bin/robot
wget -nc https://github.com/ontodev/robot/releases/download/v1.9.6/robot.jar

# Read the ontology name (first argument) and change to its directory
export ONTO="$1"
echo "__________________________________________[${ONTO}]____________________________________________"

# Fetch the ontology OWL file
wget -nc -O "external-dev/tmp/source/${ONTO}.owl" "$(grep "owl=" "config/${ONTO}.props" | cut -d'=' -f2)"

if [[ "$ONTO" == "npo" ]]; then
    echo "Reasoning NPO (ELK)"
    bash robot --prefixes "external-dev/prefixes.json" \
        reason --reasoner ELK --annotate-inferred-axioms true \
        --input "external-dev/tmp/source/${ONTO}.owl" --output "external-dev/tmp/source/${ONTO}.owl"
fi

# Define file paths for adding/removing terms
add_D="external-dev/term-files/add/${ONTO}_add_D.txt"
add="external-dev/term-files/add/${ONTO}_add.txt"
remove="external-dev/term-files/remove/${ONTO}_remove.txt"
remove_D="external-dev/term-files/remove/${ONTO}_remove_D.txt"

# Check the existence of term files
file_status="$(
    [[ -f $add ]] && echo 1 || echo 0
    [[ -f $add_D ]] && echo 1 || echo 0
    [[ -f $remove ]] && echo 1 || echo 0
    [[ -f $remove_D ]] && echo 1 || echo 0
)"

case $file_status in
    1111)
        echo "[${ONTO}] Settings: add, add_D, remove, and remove_D all existing"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add_D" \
            --select "annotations self descendants" \
            --signature false --output "external-dev/tmp/${ONTO}_add_D.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add" \
            --select "annotations self" \
            --signature false --output "external-dev/tmp/${ONTO}_add.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/${ONTO}_add_D.owl" \
            --input "external-dev/tmp/${ONTO}_add.owl" \
            --include-annotations true \
            remove --term-file "$remove_D" \
            --select "self descendants" \
            remove --term-file "$remove" \
            --select "self" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    1110)
        echo "[${ONTO}] Settings: add, add_D, and remove existing but no remove_D"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add_D" \
            --select "annotations self descendants" \
            --signature false --output "external-dev/tmp/${ONTO}_add_D.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add" \
            --select "annotations self" \
            --signature false --output "external-dev/tmp/${ONTO}_add.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/${ONTO}_add_D.owl" \
            --input "external-dev/tmp/${ONTO}_add.owl" \
            --include-annotations true \
            remove --term-file "$remove" \
            --select "self" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    1101)
        echo "[${ONTO}] Settings: add, add_D, and remove_D existing but no remove"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add_D" \
            --select "annotations self descendants" \
            --signature false --output "external-dev/tmp/${ONTO}_add_D.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add" \
            --select "annotations self" \
            --signature false --output "external-dev/tmp/${ONTO}_add.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/${ONTO}_add_D.owl" \
            --input "external-dev/tmp/${ONTO}_add.owl" \
            remove --term-file "$remove_D" \
            --select "self descendants" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    1100)
        echo "[${ONTO}] Settings: add and add_D existing but no remove or remove_D"
        bash robot --prefixes "external-dev/prefixes.json" \
            filter --input "external-dev/tmp/source/${ONTO}.owl" \
            --term-file "$add_D" \
            --select "annotations self descendants" \
            --signature false --output "external-dev/tmp/${ONTO}_add_D.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            filter --input "external-dev/tmp/source/${ONTO}.owl" \
            --term-file "$add" \
            --select "annotations self" \
            --signature false \
            merge --input "external-dev/tmp/${ONTO}_add_D.owl" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    1011)
        echo "[${ONTO}] Settings: add, remove, and remove_D existing but no add_D"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add" \
            --select "annotations self" \
            --signature false --output "external-dev/tmp/${ONTO}_add.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/${ONTO}_add_D.owl" \
            --input "external-dev/tmp/${ONTO}_add.owl" \
            remove --term-file "$remove_D" \
            --select "self descendants" \
            remove --term-file "$remove" \
            --select "self" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    1010)
        echo "[${ONTO}] Settings: add and remove existing but no add_D or remove_D"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add" \
            --select "annotations self" \
            --signature false --output "external-dev/tmp/${ONTO}_add.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            remove --input "external-dev/tmp/${ONTO}_add.owl" \
            --term-file "$remove" \
            --select "self" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    1001)
        echo "[${ONTO}] Settings: add and remove_D existing but no add_D or remove"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add" \
            --select "annotations self" \
            --signature false --output "external-dev/tmp/${ONTO}_add.owl"

        bash robot --prefixes "external-dev/prefixes.json" \
            remove --input "external-dev/tmp/${ONTO}_add.owl" \
            --term-file "$remove_D" \
            --select "self descendants" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    1000)
        echo "[${ONTO}] Settings: only add existing"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add" \
            --select "annotations self" \
            --signature false --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    0111)
        echo "[${ONTO}] Settings: add_D, remove, and remove_D existing but no add"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add_D" \
            --select "annotations self descendants" \
            --signature false \
            remove --term-file "$remove_D" \
            --select "self descendants" \
            remove --term-file "$remove" \
            --select "self" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    0110)
        echo "[${ONTO}] Settings: add_D and remove existing but no add or remove_D"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add_D" \
            --select "annotations self descendants" \
            --signature false \
            remove --term-file "$remove" \
            --select "self" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    0101)
        echo "[${ONTO}] Settings: add_D and remove_D existing but no add or remove"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add_D" \
            --select "annotations self descendants" \
            --signature false --output "external-dev/tmp/${ONTO}_add_D.owl" \
            remove --term-file "$remove_D" \
            --select "self descendants" \
            --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
    0100)
        echo "[${ONTO}] Settings: only add_D existing"
        bash robot --prefixes "external-dev/prefixes.json" \
            merge --input "external-dev/tmp/source/${ONTO}.owl" \
            filter --term-file "$add_D" \
            --select "annotations self descendants" \
            --signature false --output "external-dev/tmp/${ONTO}_no_spcs.owl"
        ;;
esac

echo "...Done filtering source ontology ${ONTO}"

# Template subclassOf assertions
timestamp=$(date -I)
if [[ -f "external-dev/templates/${ONTO}_subclass_assertion.csv" ]]; then
    echo "Injecting SC via template."
    bash robot --prefixes "external-dev/prefixes.json" \
        template --template "external-dev/templates/${ONTO}_subclass_assertion.csv" \
        --output "external-dev/tmp/${ONTO}_spcs.owl"

    bash robot --prefixes "external-dev/prefixes.json" \
        merge --include-annotations true \
        --input "external-dev/tmp/${ONTO}_no_spcs.owl" \
        --input "external-dev/tmp/${ONTO}_spcs.owl" \
        --output "external-dev/${ONTO}-ext.owl" \
        annotate --ontology-iri "http://purl.enanomapper.net/onto/external/${ONTO}-slim.owl" \
        --version-iri "https://purl.enanomapper.org/onto/external-dev/${ONTO}-ext-prop.owl/" \
        --annotation http://www.w3.org/2002/07/owl#versionInfo "This ontology subset was generated automatically with ROBOT (http://robot.obolibrary.org)" \
        --annotation http://www.geneontology.org/formats/oboInOwl#date "$timestamp (yyyy-mm-dd)"
else
    cp "external-dev/tmp/${ONTO}_no_spcs.owl" "external-dev/${ONTO}-ext.owl"
fi

# Add properties, if they exist
if [[ -f "config/${ONTO}-term-file.txt" ]]; then 
    echo "Extracting object and data properties"
    cp "config/${ONTO}-term-file.txt" "external-dev/props/${ONTO}-term-file.txt"
    bash robot --prefixes "external-dev/prefixes.json" \
        extract --method subset \
        --input "external-dev/tmp/source/${ONTO}.owl" \
        --term-file "external-dev/props/${ONTO}-term-file.txt" \
        annotate --version-iri "https://purl.enanomapper.org/onto/external-dev/${ONTO}-ext-prop.owl/" \
        --ontology-iri "https://purl.enanomapper.org/onto/external-dev/${ONTO}-ext.owl/" \
        --output "external-dev/${ONTO}-ext-prop.owl"
fi
