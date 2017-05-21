Ontologies
==========

The eNanoMapper ontologies aim to provide a comprehensive suite of ontologies for the nanomaterial safety assessment domain (see http://www.enanomapper.net for project information). The full suite of ontologies can be found assembled by imports in the primary enanomapper.owl file. 


Internal
--------
ontology-metadata-slim.owl - excerpt of the IAO (http://information-artifact-ontology.googlecode.com/) including metadata (annotation properties) only. 
nm.owl - nanomaterial descriptors ontology using the CHEMINF ontology


External
--------
We import the NanoParticle Ontology (see http://nano-ontology.org); CHEMINF (http://code.google.com/p/semanticchemistry/); parts of ChEBI (http://www.ebi.ac.uk/chebi); and others (TBD). 

DOI
--------
Version 3: [![DOI](https://zenodo.org/badge/20764/enanomapper/ontologies.svg)](https://zenodo.org/badge/latestdoi/20764/enanomapper/ontologies)

Version 4: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.260098.svg)](https://doi.org/10.5281/zenodo.260098)

Building and validating the ontology
====================================

During (and after) the eNanoMapper project the ontology was autobuilt using scripts on
[a Jenkins server](https://jenm.bigcat.maastrichtuniversity.nl/). The main OWL file (enanomapper.owl)
refers to slimmed versions of external ontologies, complemented with internal files adding additional
terms. The slimming of the external ontologies is done with the Slimmer tool, with these commands (for the
BioAssay Ontology):

    rm -f *.owl
    rm -f *.owl.*
    wget -O bao_complete.owl http://www.bioassayontology.org/bao/bao_complete.owl
    rm -f bao.props*
    rm -f bao.iris*
    wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/bao.props
    wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/bao.iris
    java -cp ../Slimmer/target/slimmer-0.0.1-SNAPSHOT-jar-with-dependencies.jar com.github.enanomapper.Slimmer .

The bao.props and bao.iris files contain all the information needed to describe which parts of the BAO ontology
is retained in the slimmed version.

Making Releases
===============

The following steps ...
