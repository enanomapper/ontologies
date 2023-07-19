#!/bin/bash
# Read the ontology name (first argument) and change to its directory
export ONTO=$1
slimmer=$(ls | grep *with-dependencies.jar)
echo "Slimmer version: '${slimmer}'"

ls
mkdir -p external-dev/${ONTO}
rm external-dev/${ONTO}-slim.owl
echo ${ONTO}-slim.owl removed
cd external-dev/${ONTO}
    
   
wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.props --no-cache
wget -N --no-cache `grep "owl=" ${ONTO}.props | cut -d'=' -f2` -O ${ONTO}.owl
wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.iris --no-cache
    
    
# Run slimmer
    
java -cp ../../$slimmer com.github.enanomapper.Slimmer .


    
# Rename slimmed file to proper name
mv *-slim.owl ../${ONTO}-slim.owl
cd ../
rm -r ${ONTO}
ls
# Check if slimmed file was created
    
if [ -f ${ONTO}-slim.owl ] ; then
    echo Automated ${ONTO} slimming run on `date` 
fi
    
if [ ! -f ${ONTO}-slim.owl ]; then
    echo Failed ${ONTO} slimming on `date`
    exit 1
fi


