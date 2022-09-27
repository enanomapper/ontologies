#!/bin/bash
# Read the ontology name (first argument) and change to its directory
export ONTO=$1
mkdir -p ontologies
cd ontologies


wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.props
wget `grep "owl=" ${ONTO}.props | cut -d'=' -f2`
ontology=$(basename `grep "owl=" ${ONTO}.props | cut -d'=' -f2`)

wget https://github.com/ontodev/robot/releases/download/v1.7.0/robot.jar
curl https://raw.githubusercontent.com/ontodev/robot/master/bin/robot > robot

if [ ${ONTO} == "bao" ]; then 
    ARGS=$"--term "http://www.bioassayontology.org/bao#BAO_0000209" --select annotations"
fi

if [ ${ONTO} == "cito" ]; then 
    ARGS=$"--term "http://purl.org/spar/cito/cites" --select 'annotations self descendants'"
fi

if [ ${ONTO} == "ro" ]; then 
    ARGS=$"--term "http://purl.obolibrary.org/obo/RO_0000056" --select annotations"
fi

if [ ${ONTO} == "sio" ]; then 
    ARGS=$"--term-file ../config/sio-term-file.txt --select annotations"
fi

if [ ${ONTO} == "npo" ]; then 
    ARGS=$"--term "http://purl.bioontology.org/ontology/npo#has_part" --select annotations"
fi

sh ./robot filter --input ${ontology} ${ARGS} --output ${ONTO}-slim-prop.owl