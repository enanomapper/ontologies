#!/usr/local/bin/python

#Generates a GitHub Actions workflow configuration file "Build slims" in YAML format 
#based on the contents of "enanomapper.yaml". The script reads and parses the contents of this file, 
#and then extracts specific values from it to use in the configuration file.  
#Then, it iterates over lists of ontologies and properties stored in "slim" and "props", writing steps to 
#the configuration file to apply each one using shell scripts. Finally, it writes a step to 
#commit and push the modified OWL files to the repository.

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
  schedule = build["schedule"]
  with open("../../../.github/workflows/slim-ontologies.yml", "a+") as  build_yaml:
    # Writes serialization for the workflow dispatch and getting slimmer
    build_yaml.truncate(0)
    build_yaml.write(f"""name: Build slims
on:
  {dispatch}
  schedule:
    - cron: {schedule}
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
    build_yaml.write("""
  # slim all ontologies
  # Authorize running slim script
    - name: authorize running slim scripts
      run: chmod 755 scripts/src/build-workflow/*.sh
  """)
    # Apply slims
    for ontology in slim:
      build_yaml.write(f"""
  # Slim {ontology}
    - name: slim-{ontology}
      run: bash scripts/src/build-workflow/slim.sh {ontology}
  """)
    # Apply props
    for prop in props:
      build_yaml.write(f"""
  # apply props {prop}
    - name: Apply props {prop}
      run: bash scripts/src/build-workflow/props.sh {prop}
  """)

    # Commit and push
    build_yaml.write(f"""
  # Commit and push
    - name: Commit OWL files
      run: |
        git add external-dev/*.owl
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git commit -m "{commit_message}" ./external-dev/*.owl
        git push -f
  """)

if __name__ == "__main__":
    main()
