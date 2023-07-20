#!/bin/bash
# Read the ontology name (first argument) and change to its directory
export ONTO=$1

mkdir -p external-dev/${ONTO}
cd external-dev/${ONTO}
echo "------Retrieving dependencies for ${ONTO}------"
wget -nc https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.props
wget `grep "owl=" ${ONTO}.props | cut -d'=' -f2`
ontology=$(basename `grep "owl=" ${ONTO}.props | cut -d'=' -f2`)

echo "------Applying props for ${ONTO}------"
ls
sh ../../robot filter --input ${ontology} --term-file ../../config/${ONTO}-term-file.txt --output ../${ONTO}-slim-prop.owl

cd ../../
rm -r external-dev/${ONTO}
# Check if props file was created
    
if [ -f external-dev/${ONTO}-slim-prop.owl ] ; then
    echo Automated ${ONTO} prop extraction run on `date` 
fi
    
if [ ! -f external-dev/${ONTO}-slim-prop.owl ]; then
    echo Failed ${ONTO} prop extraction on `date`
    exit 1
fi

