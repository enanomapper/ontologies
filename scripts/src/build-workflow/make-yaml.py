#!/usr/local/bin/python

# Variables used throughout the script
ontologies = ["aopo", "bao","bfo","bto","ccont","cheminf","cito","chebi","chmo","clo","efo","envo","fabio","go","hupson","iao","ncit","npo","oae","obcs","obi","pato","ro","sio","uberon","uo"]

props = ["bao", "cheminf","npo", "sio", "ro", "cito"]

test_location = "test"

assignees = "jmillanacosta"

# Opens the yaml file
with open("../../../.github/workflows/slim-ontologies.yml", "a+") as f:
  # Writes serialization for the workflow dispatch and getting slimmer
  f.truncate(0)
  f.write("""name: workflow slim ontologies
on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Check out repository
      uses: actions/checkout@v3
    # Get slimmer
    - name: get slimmer
      run: wget -nc https://github.com/enanomapper/slimmer/releases/download/v1.0.2/slimmer-1.0.2-jar-with-dependencies.jar 
  """)

  # Writes serialization to slim all ontologies
  f.write("""
  # slim all ontologies
  # Authorize running slim script
    - name: authorize running slim scripts
      run: chmod 755 scripts/src/build-workflow/*.sh
  """)
  # Apply slims
  for ontology in ontologies:
    f.write("""
  # Slim {}
    - name: slim-{}
      run: bash scripts/src/build-workflow/slim.sh {}
  """.format(ontology, ontology, ontology))
  # Apply props
  for prop in props:
    f.write("""
  # apply props {}
    - name: Apply props {}
      run: bash scripts/src/build-workflow/props.sh {}
  """.format(prop, prop, prop))
  
  # PR
  f.write("""
  # Create PR
    - name: Create Pull Request
      uses: peter-evans/create-pull-request@v3
      with:
        commit-message: Update release files
        title: 'Update release files'
        body: |
          Updates all release files.
        assignees: {}    
  """.format(assignees))