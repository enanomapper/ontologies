#!/usr/local/bin/python
import yaml

def import_settings(my_yaml):
  """Opens a yaml file and return its loads"""
  with open(my_yaml, "r") as stream:
      try:
          config = yaml.safe_load(stream)
      except yaml.YAMLError as exc:
          print(exc)
  return config

def main():
  """Writes the build yaml for GH actions passing the loads from enanomapper.yaml"""
  config = import_settings("enanomapper.yaml")
  slim = config["slim"]
  props = config["props"]
  build = config["build"]
  dispatch = build["dispatch"]
  commit_message= build["commit_message"]
  with open("../../../.github/workflows/slim-ontologies.yml", "a+") as  build_yaml:
    # Writes serialization for the workflow dispatch and getting slimmer
    build_yaml.truncate(0)
    build_yaml.write("""name: workflow slim ontologies
on:
  {}
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Check out repository
      uses: actions/checkout@v3
    # Get slimmer
    - name: get slimmer
      run: wget -nc https://github.com/enanomapper/slimmer/releases/download/v1.0.2/slimmer-1.0.2-jar-with-dependencies.jar
  """.format(dispatch))

    # Writes serialization to slim all ontologies
    build_yaml.write("""
  # slim all ontologies
  # Authorize running slim script
    - name: authorize running slimscripts
      run: chmod 755 scripts/srcbuild-workflow/*.sh
  """)
    # Apply slims
    for ontology in slim:
      build_yaml.write("""
  # Slim {}
    - name: slim-{}
      run: bash scripts/srcbuild-workflow/slim.sh {}
  """.format(ontology, ontology, ontology))
    # Apply props
    for prop in props:
      build_yaml.write("""
  # apply props {}
    - name: Apply props {}
      run: bash scripts/srcbuild-workflow/props.sh {}
  """.format(prop, prop, prop))

    # Commit and push
    build_yaml.write("""
  # Commit and push
    - name: Commit OWL files
      run: |
        git add external/*.owl
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git commit -m "{}" .external/*.owl
    - name: Push changes
      uses: ad-m/github-push-action@master
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        branch: ${{ github.ref }}   
  """.format(commit_message))

if __name__ == "__main__":
    main()