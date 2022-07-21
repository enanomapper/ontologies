#!/bin/bash
# Read the ontology name (first argument) and change to its directory
export ONTO=$1
if [ ${ONTO} == "$ncit" ]; then 
    ./slim-ncit.sh
    else
    
    ls
    mkdir -p external/${ONTO}
    cd external/${ONTO}
   
   
    wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/${ONTO}.props
    wget  `grep "owl=" ${ONTO}.props | cut -d'=' -f2`
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
        echo Automated ${ONTO} slimmed build run on `date` >> ../../runs.txt
    fi
    
    if [ ! -f ${ONTO}-slim.owl ]; then
        echo Failed ${ONTO} slimming on `date` >> ../../runs.txt
    fi

fi