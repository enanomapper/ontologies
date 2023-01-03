#!/bin/bash
# Read the ontology name (first argument) and change to its directory
export ONTO=$1
wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.props
wget -N  `grep "owl=" ${ONTO}.props | cut -d'=' -f2`
wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.iris
    
if [ ${ONTO} = "ncit" ]; then 
    wget https://data.bioontology.org/ontologies/NCIT/submissions/116/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb -O ncit.owl

elif [ ${ONTO} = "hupson" ]; then 
    wget http://data.bioontology.org/ontologies/HUPSON/submissions/1/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb -O hupson.owl

else   
    ls
    mkdir -p external-dev/${ONTO}
    rm external-dev/${ONTO}-slim.owl
    echo ${ONTO}-slim.owl removed
    cd external-dev/${ONTO}
    
   
    wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.props
    wget -N  `grep "owl=" ${ONTO}.props | cut -d'=' -f2`
    wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.iris
    
    
    # Run slimmer
    
    java -cp ../../slimmer-1.0.2-jar-with-dependencies.jar com.github.enanomapper.Slimmer .
    
    # Remove original owl file
    ontology=$(basename `grep "owl=" ${ONTO}.props | cut -d'=' -f2`)
    rm -f $ontology
    
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

fi
