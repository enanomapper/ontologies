The eNanoMapper Ontology 
============

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8139894.svg)](https://doi.org/10.5281/zenodo.8139894)
[![Build slims](https://github.com/enanomapper/ontologies/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/enanomapper/ontologies/actions/workflows/build.yml)
[![On push file integrity tests](https://github.com/enanomapper/ontologies/actions/workflows/on-push-tests.yml/badge.svg?branch=master)](https://github.com/enanomapper/ontologies/actions/workflows/on-push-tests.yml)
[![ROBOT enanomapper-dev build test](https://github.com/enanomapper/ontologies/actions/workflows/dev-tests.yml/badge.svg?branch=master)](https://github.com/enanomapper/ontologies/actions/workflows/dev-tests.yml)
[![Pre-release tests](https://github.com/enanomapper/ontologies/actions/workflows/prerelease-tests.yml/badge.svg?branch=master)](https://github.com/enanomapper/ontologies/actions/workflows/prerelease-tests.yml)


The eNanoMapper ontologies aim to provide a comprehensive suite of ontologies for the nanomaterial safety assessment domain (see http://www.enanomapper.net for project information). The full suite of ontologies can be found in a modular file assembled by imports using `owl:imports`, [enanomapper.owl](enanomapper.owl).

The ontology is being developed and maintained by the following EU H2020 projects (see also the below
[funding](README.md#funding) info):

* [NanoSolveIT](https://www.nanosolveit.eu/)
* [NanoCommons](https://www.nanocommons.eu/) (project ended)
* [OpenRiskNet](https://openrisknet.org/) (project ended)
* [eNanoMapper](http://enanomapper.net/) (project ended)

Other NanoSafety Cluster projects that have contributed by providing feedback and collaborations
include [NANoREG](http://www.nanoreg.eu/), [NanoReg2](http://www.nanoreg2.eu/), and 
[GRACIOUS](https://www.h2020gracious.eu/).

External
--------
We import slices from third party ontologies. The Slimmer tool is used to extract the bits we include
in the eNanoMapper ontology. The slimmed files can be found in the [external](external) folder.
The full list of ontologies it includes is:

* [Adverse Outcome Pathways Ontology](https://github.com/DataSciBurgoon/aop-ontology) (AOP)
* [BioAssay Ontology](http://bioassayontology.org/) (BAO)
* [Basic Formal Ontology](http://basic-formal-ontology.org/) (BFO)
* [Cell Culture Ontology](http://bioportal.bioontology.org/ontologies/CCONT?p=summary) (CCONT)
* [Chemical Entities of Biological Interest](https://www.ebi.ac.uk/chebi/) (CHEBI)
* [Chemical Information Ontology](https://github.com/semanticchemistry/semanticchemistry/) (CHEMINF)
* [Chemical Methods Ontology](https://github.com/rsc-ontologies/rsc-cmo) (CHMO)
* [Citation Typing Ontology](http://purl.org/spar/cito) (CITO)
* [Experimental Factor Ontology](https://www.ebi.ac.uk/efo/) (EFO)
* [Environment Ontology](http://environmentontology.org/) (ENVO)
* [FRBR-aligned Bibliographic Ontology](https://sparontologies.github.io/fabio/current/fabio.html) (FABIO)
* [Gene Ontology](http://www.geneontology.org/) (GO)
* [Information Artifact Ontology](https://github.com/information-artifact-ontology/IAO/) (IAO)
* [National Cancer Institute Thesaurus](https://nciterms.nci.nih.gov/) (NCIT)
* [NanoParticle Ontology](http://www.nano-ontology.org/) (NPO)
* [Ontology of Adverse Events](http://www.oae-ontology.org/) (OAE)
* [Ontology of Biological and Clinical Statistics](https://github.com/obcs/obcs) (OBCS)
* [Ontology for Biomedical Investigations](http://obi-ontology.org/) (OBI)
* [Phenotype And Trait Ontology](https://github.com/pato-ontology/pato) (PATO)
* [Semanticscience Integrated Ontology](https://github.com/micheldumontier/semanticscience) (SIO)
* [Uber Anatomy Ontology](https://github.com/obophenotype/uberon) (UBERON)
* [Unit Ontology](https://github.com/bio-ontology-research-group/unit-ontology) (UO)

![slims-dependencies](https://github.com/enanomapper/ontologies/blob/master/assets/slims_graph.png?raw=true)
![slims-count](https://github.com/enanomapper/ontologies/blob/master/assets/count_prefix.png?raw=true)

The build of the slims is carried out in this repository through the actions contained in the [
.github/workflows](.github/workflows) folder,
and the resulting slims of external ontologies are commited and pushed automatically to this repository when 
the build workflow is run under [external-dev](external-dev).

The configuration file [config.yaml](config.yaml) is used by the build and test workflows to retrieve `ROBOT` and `Slimmer`. There are 3 test workflows:
-  On push: test for file integrity (`external`, `external-dev`, `internal`, `internal-dev`, `config`) and performs SPARQL queries on `enanomapper-dev.owl` to make sure internal terms have not been added at the top of the class hierarchy or directly under `entity`.
- Development tests: `robot diff` and `robot report` are performed after each build for QC on the resulting development version of the ontology, with their results being stored as artifacts after each run.
- Pre-release tests: ensure the modules are updated and the ontology is satisfiable and has the right top-level class hierarchy before making a release. This is the only test that needs to be dispatched manually.


DOI of Releases
---------------
* Version 10: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8139894.svg)](https://doi.org/10.5281/zenodo.8139894)
* Version 9: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7503729.svg)](https://doi.org/10.5281/zenodo.7503729)
* Version 8: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6984499.svg)](https://doi.org/10.5281/zenodo.6984499)
* Version 7: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4600986.svg)](https://doi.org/10.5281/zenodo.4600986)
* Version 6: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3382100.svg)](https://doi.org/10.5281/zenodo.3382100)
* Version 5: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3237535.svg)](https://doi.org/10.5281/zenodo.3237535)
* Version 4: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.260098.svg)](https://doi.org/10.5281/zenodo.260098)
* Version 3: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.47119.svg)](https://doi.org/10.5281/zenodo.47119)

Opening the ontology in Protégé
===============================

The stable version can be opened in [Protégé](https://protege.stanford.edu/) with the following step:

1. File → Open from URL...
2. enter the URL http://enanomapper.github.io/ontologies/enanomapper.owl

The development version is opened in the same way, but with a different URL:

1. File → Open from URL...
2. enter the URL http://enanomapper.github.io/ontologies/enanomapper-dev.owl

Building and validating the ontology
====================================

During (and after) the eNanoMapper project the ontology was autobuilt using scripts on the [BiGCaT
Jenkins server](https://jenm.bigcat.maastrichtuniversity.nl/). After the cyberattack on Maastricht University 
in 2019, this repository uses GitHub Actions to replicate the Jenkins build process, and adds a [full ontology file](enanomapper-full.owl) and customizable workflows for ontology build and QC.

The main OWL file (enanomapper.owl) refers to slimmed versions of external ontologies, complemented with internal 
files adding additional terms. The extensions are OWL files themselves and you can load them in Protégé
and use the ```internal/Makefile``` to run ```xmllint``` on the extensions to see if the OWL
files are well-formed.

The slimming of the external ontologies is done with the Slimmer tool, with these commands (for the
BioAssay Ontology):

```shell
rm -f *.owl
rm -f *.owl.*
wget -O bao_complete.owl http://www.bioassayontology.org/bao/bao_complete.owl
rm -f bao.props*
rm -f bao.iris*
wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/bao.props
wget https://raw.githubusercontent.com/enanomapper/ontologies/master/config/bao.iris
java -cp ../Slimmer/target/slimmer-0.0.1-SNAPSHOT-jar-with-dependencies.jar com.github.enanomapper.Slimmer .
```

The bao.props and bao.iris files contain all the information needed to describe which parts of the BAO ontology
is retained in the slimmed version. This is automatically applied for all modules in the `build` workflow once a month.

Tutorials
=========

Please also check out these tutorials, developed by eNanoMapper, NanoCommons, and OpenRiskNet:

* [Browsing the eNM ontology with BioPortal, AberOWL and Protégé](https://enanomapper.github.io/tutorials/BrowseOntology/Tutorial%20browsing%20eNM%20ontology.html)
* [Adding ontology terms](https://enanomapper.github.io/tutorials/Added%20ontology%20terms/README.html)

Making Releases
===============


1. Check if the metadata in the enanomapper.owl is up to data (e.g. names of people who submitted PRs)
2. Copy the internal ontologies in `ontologies/internal-dev/` to `ontologies/internal` and  `ontologies/external-dev/` to `ontologies/external`
3. Update for `enanomapper.owl` and `enanomapper-dev.owl`:
   * `owl:versionInfo`
   * `owl:versionIRI` (only `enanomapper.owl`)
4. Create a folder `releases/{version}` and store there a copy of the latest `enanomapper.owl` file
5. Make a git commit with the changes and tag that commit matching the release
6. Manually dispatch the `prerelease-test` workflow and make the pertinent fixes if it fails. Repeat the tagged git commit after fixing the issues.
7. Update the CITATION.cff
   * `title`
   * `version`
   * `date-released`
8. Write markdown for the release with the changes since the previous release
9. Release the whole repository in GitHub https://github.com/enanomapper/ontologies/releases 
10. Update the DOI number for new release: https://zenodo.org/record/260098

Funding
=======

The project has had contributions from various European Commission projects. The
[eNanoMapper](http://enanomapper.net/) project was funded by the European Union’s Seventh
Framework Programme for research, technological development and demonstration
(FP7-NMP-2013-SMALL-7) under grant agreement no. [604134](https://cordis.europa.eu/project/rcn/110961/factsheet/en).
[NanoCommons](https://www.nanocommons.eu/) has received funding from European Union Horizon
2020 Programme (H2020) under grant agreement nº [731032](https://cordis.europa.eu/project/rcn/212586/factsheet/en).
[OpenRiskNet](https://openrisknet.org/) is funded by the European Commission within Horizon 2020
EINFRA-22-2016 Programme under grant agreement no. [731075](https://cordis.europa.eu/project/rcn/206759/factsheet/en).
[NanoSolveIt](https://www.nanosolveit.eu/) has received funding from European Union Horizon
2020 Programme (H2020) under grant agreement no. 814572.

