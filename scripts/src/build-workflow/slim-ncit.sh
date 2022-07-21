#!/bin/bash
export ONTO=ncit
mkdir -p external/${ONTO}
cd external/${ONTO}

wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.props
wget -O "download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb" https://data.bioontology.org/ontologies/NCIT/submissions/116/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb

wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.iris
wget -nc https://github.com/enanomapper/slimmer/releases/download/v1.0.2/slimmer-1.0.2-jar-with-dependencies.jar
java -cp ../../slimmer-1.0.2-jar-with-dependencies.jar com.github.enanomapper.Slimmer .

rm "download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb"

# Rename slimmed file to proper name
mv *-slim.owl ../{ONTO}-slim.owl


# Check if slimmed file was created
FILE = ${ONTO}-slim.owl

if [ -f "$FILE" ]; then
    echo Automated ${ONTO} slimmed build ${FILE} run on `date` >> ../../runs.txt
fi

if [ ! -f "$FILE" ]; then
    echo Failed ${ONTO} slimmed build on `date` >> ../../runs.txt
fi