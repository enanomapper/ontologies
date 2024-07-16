ROBOT="https://github.com/ontodev/robot/raw/master/bin/robot"
ROBOT_JAR="https://github.com/ontodev/robot/releases/download/v1.9.5/robot.jar"
# Download ROBOT
wget -nc $ROBOT
wget -nc $ROBOT_JAR
# Export eNMO v10.0 internal terms to tabular format
# Assays
sh robot \
        export  --input internal-dev/bao-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/assay.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice

# Endpoints
sh robot \
        export  --input internal-dev/endpoints.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/endpoints.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
# Chemical entities
sh robot \
        export  --input internal-dev/chebi-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/chemical_entities.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice
# ENMs
sh robot \
        export  --input internal-dev/npo-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/enms.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice

# PChem
sh robot \
        export  --input internal-dev/bfo-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/pchem.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice

# Chemical methods
sh robot \
        export  --input internal-dev/chmo-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/chemical_methods.csv \
                --entity-format IRI \
                --include "classes properties individuals"
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice

# Experimental factors
sh robot \
        export  --input internal-dev/efo-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/experimental_factors.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice

# Biological process
sh robot \
        export  --input internal-dev/go-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/biological_process.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice


# Experimental factors
sh robot \
        export  --input internal-dev/efo-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/experimental_factors.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice

# Computational methods
sh robot \
        export  --input internal-dev/iao-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/computational_methods.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice

# NCIT
sh robot \
        export  --input internal-dev/ncit-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/cell_line.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice        


# Regulation, guidance, governance


# Descriptors
sh robot \
        export  --input internal-dev/descriptors/nm.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/qsar.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice  

# Information content entities
sh robot \
        export  --input internal-dev/iao-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/information_content.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice  

# Units
sh robot \
        export  --input internal-dev/uo-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/units.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice  

# Units
sh robot \
        export  --input internal-dev/uo-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/units.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice  

# Units
sh robot \
        export  --input internal-dev/uo-ext.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/units.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice  

# Life cycle
sh robot \
        export  --input internal-dev/nmlco.owl \
                --header "ID|LABEL|IRI|SYNONYMS|SubClass Of|SubClasses|Equivalent Class|SubProperty Of|Equivalent Property|Disjoint With|Type|Domain|Range" \
                --export internal-dev/templates/lifecycle.csv \
                --entity-format IRI \
                --include "classes properties individuals" 
        # TODO Extract authors and versions from the original
        # TODO template into an internal module
        # TODO annotate with version IRI, authors, and upstream ontology of choice  
