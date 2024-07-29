#!/usr/bin/env bash
ROBOT="https://github.com/ontodev/robot/raw/master/bin/robot"
ROBOT_JAR="https://github.com/ontodev/robot/releases/download/v1.9.5/robot.jar"
# Download ROBOT
wget -nc $ROBOT
wget -nc $ROBOT_JAR
# Annotate each entity according to intended upstream ontology
## BAO
echo BAO
sh robot \
    annotate \
        --input internal-dev/bao-ext.owl \
        --version-iri "http://www.bioassayontology.org/bao#" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/bao-int.owl 
## BFO
echo BFO
sh robot \
    annotate \
        --input internal-dev/bfo-ext.owl \
        --version-iri "http://purl.obolibrary.org/obo/bfo/" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/bfo-int.owl 
## CHEBI
echo ChEBI
sh robot \
    annotate \
        --input internal-dev/chebi-ext.owl \
        --version-iri "https://www.ebi.ac.uk/chebi/" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/chebi-int.owl 
## CHEMINF
echo CHEMINF
sh robot \
    annotate \
        --input internal-dev/cheminf-ext.owl \
        --version-iri "http://semanticchemistry.github.io/semanticchemistry/ontology/cheminf.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/cheminf-int.owl 

## CHMO
echo CHMO
sh robot \
    annotate \
        --input internal-dev/chmo-ext.owl \
        --version-iri "http://purl.obolibrary.org/obo/chmo.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/chmo-int.owl 

## EFO
echo EFO
sh robot \
    annotate \
        --input internal-dev/efo-ext.owl \
        --version-iri "http://www.ebi.ac.uk/efo/efo.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/efo-int.owl 

## GO
echo GO
sh robot \
    annotate \
        --input internal-dev/go-ext.owl \
        --version-iri "http://purl.obolibrary.org/obo/go.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/go-int.owl 

## IAO
echo IAO
sh robot \
    annotate \
        --input internal-dev/iao-ext.owl \
        --version-iri "http://purl.obolibrary.org/obo/iao.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/iao-int.owl 

## NCIT
echo NCIT
sh robot \
    annotate \
        --input internal-dev/ncit-ext.owl \
        --version-iri "http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/ncit-int.owl 

## NPO
echo NPO
sh robot \
    annotate \
        --input internal-dev/npo-ext.owl \
        --version-iri "http://purl.bioontology.org/ontology/npo" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/npo-int.owl 

## OBI
echo OBI
sh robot \
    annotate \
        --input internal-dev/obi-ext.owl \
        --version-iri "http://purl.obolibrary.org/obo/obi.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/obi-int.owl 

## PATO
echo PATO
sh robot \
    annotate \
        --input internal-dev/pato-ext.owl \
        --version-iri "http://purl.obolibrary.org/obo/pato.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/pato-int.owl 

## UO
echo UO
sh robot \
    annotate \
        --input internal-dev/uo-ext.owl \
        --version-iri "http://purl.obolibrary.org/obo/uo.owl" \
        --annotate-derived-from true \
    rename \
        --add-prefix "enm: http://purl.enanomapper.net/onto/" \
        --mapping prov:wasDerivedFrom enm:submit_to \
        --output internal-dev/uo-int.owl 

## Lifecycle
echo NMLCO
cp internal-dev/nmlco.owl internal-dev/ontologies/nmlco.owl

## Regulation
echo Wikidata
cp internal-dev/wikidata.owl internal-dev/ontologies/wikidata.owl

echo Merge all modules
# Merge all modules
       # --input "internal-dev/descriptors/nm.owl" \
       # --input "internal-dev/opentox/echa-endpoints.owl" \
sh robot \
    merge \
        --inputs "internal-dev/*int.owl" \
        --input enanomapper-dev-old.owl \
        --input "internal-dev/endpoints.owl" \
        --inputs "external-dev/*" \
        --include-annotations true \
        --output enanomapper-all.owl

echo Merge external modules
# Merge external modules
sh robot \
    merge \
        --input "enanomapper-auto-dev.owl" \
        --output enanomapper-auto-dev-full.owl


## Experiment, methods, assays
echo assays_methods.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term http://purl.bioontology.org/ontology/npo#NPO_1680 \
        --term http://www.ebi.ac.uk/efo/EFO_0002694  \
        --term http://purl.bioontology.org/ontology/npo#NPO_1616 \
        --term http://purl.bioontology.org/ontology/npo#NPO_1944 \
        --term http://purl.obolibrary.org/obo/OBI_0000070 \
        --term http://purl.bioontology.org/ontology/npo#NPO_1883 \
        --term http://purl.bioontology.org/ontology/npo#NPO_1945 \
        --term http://purl.bioontology.org/ontology/npo#NPO_1964 \
        --term http://purl.enanomapper.net/onto/ENM_2012431 \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/assays_methods.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/assays_methods.owl" \
        --output internal-dev/ontologies/assays_methods.owl


## Endpoints
echo endpoints.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term 'http://www.bioassayontology.org/bao#BAO_0000179' \
        --term 'http://semanticscience.org/resource/CHEMINF_000247' \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/endpoints.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/endpoints.owl" \
        --output internal-dev/ontologies/endpoints.owl

## Biological processes
### Subclasses of obo:GO_0008150 & GO_0002433
echo biological_processes.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term obo:GO_0008150 \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/biological_processes.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/biological_processes.owl" \
        --output internal-dev/ontologies/biological_processes.owl

## Cells, organisms (taxa) and anatomical entities
### These are the subclasses of
### - organism obo:OBI_0100026
##  - cell obo:CL_0000000
echo biological_systems.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term obo:CL_0000010 \
        --term obo:OBI_0100026 \
        --term obo:UBERON_0001062 \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/biological_entities.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/biological_entities.owl" \
        --output internal-dev/ontologies/biological_entities.owl

## Qualities and dispositions (Pchem, biological)
### These are the subclasses of 
### obo:BFO_0000019
echo qualities_dispositions.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term obo:BFO_0000019 \
        --term obo:BFO_0000016 \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/qualities_dispositions.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/qualities_dispositions.owl" \
        --output internal-dev/ontologies/qualities_dispositions.owl

# Units
### These are the subclasses of obo:UO_0000000
echo units.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term obo:UO_0000000 \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/units.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/units.owl" \
        --output internal-dev/ontologies/units.owl

# Chemical substance, molecular entity, and their parts and particles
### Chemical and material
echo chemicals_materials.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term http://purl.obolibrary.org/obo/CHEBI_59999 \
        --term http://purl.obolibrary.org/obo/ENVO_00010483 \
        --term http://purl.bioontology.org/ontology/npo#NPO_1597 \
        --term http://purl.obolibrary.org/obo/CHEBI_60004 \
        --term http://purl.obolibrary.org/obo/CHEBI_23367 \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/chemicals_materials.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/chemicals_materials.owl" \
        --output internal-dev/ontologies/chemicals_materials.owl

# Descriptors
echo descriptors.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term http://semanticscience.org/resource/CHEMINF_000123 \
        --term http://purl.enanomapper.org/onto/ENM_8000019 \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/descriptors.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/descriptors.owl" \
        --output internal-dev/ontologies/descriptors.owl

# Information content entity
echo information_content_entity.owl
sh robot \
    filter \
        --input enanomapper-all.owl \
        --term http://purl.obolibrary.org/obo/IAO_0000030 \
        --select "annotations self descendants" \
        --trim false \
        --signature false \
    remove \
        --term 'http://www.bioassayontology.org/bao#BAO_0000179' \
    unmerge \
        --input enanomapper-auto-dev-full.owl \
    annotate \
        --ontology-iri "https://raw.githubusercontent.com/enanomapper/ontologies/refactor-internal/information_content_entity.owl" \
        --version-iri "http://enanomapper.github.io/ontologies/releases/11.0/internal/ontologies/information_content_entity.owl" \
        --output internal-dev/ontologies/information_content_entity.owl

sh robot \
    unmerge \
        --input internal-dev/ontologies/information_content_entity.owl \
        --input internal-dev/ontologies/assays_methods.owl \
        --output internal-dev/ontologies/information_content_entity.owl