#!/bin/bash
# Read the ontology name (first argument) and change to its directory
export ONTO=$1
if [ ${ONTO} = "ncit" ]; then 
    wget -O "download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb" https://data.bioontology.org/ontologies/NCIT/submissions/116/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb -O ${ONTO}.owl

elif [ ${ONTO} = "hupson" ]; then 
    wget -O "download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb" http://data.bioontology.org/ontologies/HUPSON/submissions/1/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb -O ${ONTO}.owl
    

fi  

ls
mkdir -p external/${ONTO}
rm external/${ONTO}-slim.owl
echo ${ONTO}-slim.owl removed
cd external/${ONTO}

wget https://raw.githubusercontent.com/enanomapper/ontologies/master/ig/${ONTO}.props
wget -N  `grep "owl=" ${ONTO}.props | cut -d'=' -f2`
wget https://raw.githubusercontent.com/enanomapper/ontologies/master/ig/${ONTO}.iris
ontology=$(basename `grep "owl=" ${ONTO}.props | cut -d'=' -f2`)

    
# Run slimmer

java -cp ../../slimmer-1.0.2-jar-with-dependencies.jar com.githubenanomapper.Slimmer .

# Remove original owl file

rm -f $ontology
rm -f ${ONTO}.owl

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
fi

