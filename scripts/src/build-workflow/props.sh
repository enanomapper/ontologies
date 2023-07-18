#!/bin/bash
# Read the ontology name (first argument) and change to its directory
export ONTO=$1
mkdir -p ontologies

echo "Created /ontologies directory for temporary files"
cd ontologies

echo "------Retrieving props for ${ONTO}------"
wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.props
wget `grep "owl=" ${ONTO}.props | cut -d'=' -f2`
ontology=$(basename `grep "owl=" ${ONTO}.props | cut -d'=' -f2`)
wget https://github.com/ontodev/robot/releases/download/v1.7.0/robot.jar
curl https://raw.githubusercontent.com/ontodev/robot/master/bin/robot > robot

if [ ${ONTO} = "bao" ]; then 
    echo "bao-------------------------------------"
    ARGS="--term "http://www.bioassayontology.org/bao#BAO_0000209" --select annotations"
    echo "Args = ${ARGS}"


elif [ ${ONTO} = "cito" ]; then 
    wget https://raw.githubusercontent.com/SPAROntologies/cito/master/docs/current/cito.owl
    ARGS=$"--term "http://purl.org/spar/cito/cites" --select 'annotations self descendants'"
    sh ./robot filter --input cito.owl ${ARGS} --output ${ONTO}-slim-prop.owl


elif [ ${ONTO} = "ro" ]; then 
    ARGS="--term "http://purl.obolibrary.org/obo/RO_0000056" --select annotations"


elif [ ${ONTO} = "sio" ]; then 
    ARGS="--term-file ../config/sio-term-file.txt --select annotations"


elif [ ${ONTO} = "npo" ]; then 
    ARGS="--term "http://purl.bioontology.org/ontology/npo#has_part" --select annotations"
fi

if [ ${ONTO} != "cito" ]; then
    echo "------Applying props for ${ONTO}------"
    sh ./robot filter --input ${ontology} ${ARGS} --output ../external-dev/${ONTO}-slim-prop.owl
fi

# Check if props file was created
    
if [ -f ../external-dev/${ONTO}-slim-prop.owl ] ; then
    echo Automated ${ONTO} prop extraction run on `date` 
fi
    
if [ ! -f ../external-dev/${ONTO}-slim-prop.owl ]; then
    echo Failed ${ONTO} prop extraction on `date`
    exit 1
fi

echo "Removing temp files"
cd ../
rm -r ontologies
