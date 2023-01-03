#!/bin/bash
# Read the ontology name (first argument) and change to its directory
export ONTO=$1
if [ ${ONTO} = "ncit" ]; then 
    bash scripts/src/build-workflow/slim-ncit.sh

elif [ ${ONTO} = "hupson" ]; then 
    bash scripts/src/build-workflow/slim-hupson.sh

else   
    ls
    mkdir -p external/${ONTO}
    rm external/${ONTO}-slim.owl
    echo ${ONTO}-slim.owl removed
    cd external/${ONTO}
    
   
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
