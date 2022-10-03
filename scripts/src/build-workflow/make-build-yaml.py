#!/usr/local/bin/python
import yaml
with open("enanomapper.yaml", "r") as stream:
    try:
        config = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)

slim = config["slim"]
props = config["props"]
build = config["build"]
dispatch = build["dispatch"]
with open("../../../.github/workflows/slim-ontologies.yml", "a+") as build_yaml:

  # Writes serialization for the workflow dispatch and getting slimmer
  build_yaml.truncate(0)
  build_yaml.write("""name: workflow slim ontologies
on:
  {dispatch}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Check out repository
      uses: actions/checkout@v3
    # Get slimmer
    - name: get slimmer
      run: wget -nc https://github.com/enanomapper/slimmer/eleases/download/#v1.0.2/slimmer-1.0.2-jar-with-dependencies.ar 
  """)

  # Writes serialization to slim all ontologies
  build_yaml.write("""
  # slim all ontologies
  # Authorize running slim script
    - name: authorize running slim scripts
      run: chmod 755 scripts/src/build-workflow/*.sh
  """)
  # Apply slims
  for ontology in slim:
    build_yaml.write("""
  # Slim {}
    - name: slim-{}
      run: bash scripts/src/build-workflow/slim.sh {}
  """.format(ontology, ontology, ontology))
  # Apply props
  for prop in props:
    build_yaml.write("""
  # apply props {}
    - name: Apply props {}
      run: bash scripts/src/build-workflow/props.sh {}
  """.format(prop, prop, prop))
  
  # Commit and push
  build_yaml.write("""
  # Commit and push
    - name: Commit OWL files
      run: |
        git add external/*.owl
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git commit -m "Updated OWL" ./external/*.owl
    - name: Push changes
      uses: ad-m/github-push-action@master
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        branch: ${{ github.ref }}   
  """)