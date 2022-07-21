
#!/usr/local/bin/python

# Variables used throughout the script
# comment out because aopo takes forever  ontologies = ["aopo","bao","bfo","ccont","cheminf","chmo","efo","fabio","go","hupson","iao","ncit","npo","oae","obcs","obi","pato","sio","uo"]
ontologies = ["bao","bfo","ccont","cheminf","chmo","efo","fabio","go","iao","ncit","npo","oae","obcs","obi","pato","sio","uo"]

#props = ["bao", "cheminf","npo", "sio"] props npo keeps failing, removed for testing
props = ["bao", "cheminf", "sio"]

test_location = "test"

# Opens the yaml file
with open("../../../.github/workflows/slim-ontologies.yml", "a+") as f:
  # Writes serialization for the workflow dispatch and getting slimmer
  f.write("""name: workflow slim ontologies
on:
  workflow_dispatch:

jobs:
  get-scripts:
    runs-on: ubuntu-latest
    steps:
    - name: Check out repository
      uses: actions/checkout@v3
    # Get slimmer
    - name: get slimmer
      run: wget -nc https://github.com/enanomapper/slimmer/releases/download/v1.0.2/slimmer-1.0.2-jar-with-dependencies.jar 
    # Keep artifact
    - name: artifact slimmer 
      uses: actions/upload-artifact@v2
      with:
        name: slimmer
        path: slimmer-1.0.2-jar-with-dependencies.jar
      

# slim all ontologies
  """)

  # Writes serialization to slim all ontologies
  for ontology in ontologies:
    f.write("""
# slim {}
  slim-{}:
    runs-on: ubuntu-latest
    needs: get-scripts
    steps:
    - name: Check out repository
      uses: actions/checkout@v3
    # Authorize running slim script
    - name: authorize running slim.sh and slim-ncit.sh
      run: chmod 755 scripts/src/build-workflow/slim.sh scripts/src/build-workflow/slim-ncit.sh
    - name: get slimmer
      uses: actions/download-artifact@v2
      with:
       name: slimmer 
    - name: slim {}
      run: bash scripts/src/build-workflow/slim.sh {}

  # apply props
      """.format(ontology,ontology,ontology,ontology,ontology,ontology))

  # Apply props
  for prop in props:
    f.write("""
# apply props {}
  props-{}:
    runs-on: ubuntu-latest
    needs: slim-{}
    steps:
    - name: Check out repository
      uses: actions/checkout@v3
    - name: Apply props {}
      run: bash scripts/src/build-workflow/props.sh {}
    # )
    """.format(prop, prop, prop, prop, prop))
  # Tests
  f.write("""
  retrieve-owl-artifacts:
    # Keep slimmed ontology as an artifact
    runs-on: ubuntu-latest
    needs: slim-{}
    steps:
    - name: owl slims artifact
      uses: actions/upload-artifact@v2
      with:
        name: owl-slims
        path: ./external/*slim.owl""".format(("[slim-" + ", slim-".join(ontologies) + "]").replace("'","")))



  ## test
  #test:
  #  runs-on: ubuntu-latest
  #  needs: {}
  #  steps:
  #  - name: Check out repository
  #    uses: actions/checkout@v3
  #  - name: Run mvn clean test 
  #    run: |
  #     cd test 
  #     mvn clean
  #     cd ../
  #     zip –r ../test.zip test
  #  # Keep tests as artifact
  #  - name: artifact tests
  #    uses: actions/upload-artifact@v2
  #    with:
  #      name: test
  #      path: test.zip
  #""".format(("[slim-" + ", slim-".join(ontologies) + "]").replace("'","")))