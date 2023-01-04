#!/usr/local/bin/python

#Generates a GitHub Actions workflow configuration file based on the contents of another 
#YAML file, "enanomapper.yaml". It reads and parses the contents of this file and extracts 
#specific values from it to use in the configuration file. The script then opens "robot.yml" 
#and truncates it to clear its contents before writing the configuration 
#file and steps for ROBOT merge and report. Finally, writes 
#a step to commit and pushes the modified files to the repository.

from makeBuild import import_settings

def main():
    """Writes the qc yaml for GH actions passing the loads from enanomapper.yaml"""
    config = import_settings("enanomapper.yaml")
    robot = config["robot-commands"]["robot"]
    robot_jar = config["robot-commands"]["robot-jar"]
    merge = config["robot-commands"]["merge"]
    verify = config["robot-commands"]["verify"]
    report = config["robot-commands"]["report"]
    validate = config["robot-commands"]["validate-profile"]
    odk_dashboard = config["odk-dashboard"]
    dispatch = config["robot-commands"]["dispatch"]
    dispatches_robot = config["build"]["dispatches_robot"]
    keep_files = config["robot-commands"]["keep_files"]
    if dispatches_robot == True:
      dispatch_robot = """
  workflow_run:
    workflows: ["Build slims"]
    types:
      - completed
    """
    else:
      dispatch_robot = ""
    commit_message = config["robot-commands"]["commit-message"]
    reason = config["robot-commands"]["reason"]["value"]
    reasoner = config["robot-commands"]["reason"]["reasoner"]
    #cron = config["robot-commands"]["schedule"]
    added_merged = ""
    with open("../../../.github/workflows/robot.yml", "a+") as robot_yaml:
        robot_yaml.truncate(0)
        robot_yaml.write(f"""name: ROBOT-commands
on:
  {dispatch}
    {dispatch_robot}

jobs:
    robot-workflows:
        runs-on: ubuntu-latest
        steps:
        - name: checkout repo
          uses: actions/checkout@v2
        - name: get robot
          run: |
            ls
            wget {robot}
            wget {robot_jar}
            chmod 777 robo*
            mkdir -p robot-report
    """)
        if merge == True:
            robot_yaml.write("""
        - name: merge
          run: | 
            sh robot merge -i enanomapper-dev.owl -o enanomapper-dev-full.owl
            sh robot merge -i enanomapper.owl -o enanomapper-full.owl
            """)
            added_merged = "git add enanomapper-full.owl"
        if verify == True:
            pass
        if report == True:
          robot_yaml.write("""
        - name: report
          run: sh robot report --fail-on none -i enanomapper-dev-full.owl -o robot-report/report.tsv
        - name: diff
          run: |
            sh robot diff --left enanomapper-full.owl --right enanomapper-dev-full.owl --output robot-report/diff.txt
            """)
          if keep_files == False:
            robot_yaml.write("""
            rm enanomapper-full.owl
            rm enanomapper-dev-full.owl
            """)
        added_report = "git add ./robot-report/*"
        if validate == True:
            pass # to be added
        if odk_dashboard == True:
            pass # to be added
        #if reason == True and reasoner in ["ELK", "hermit", "jfact", "whelk"]:
        #  robot_yaml.write(f"""
        #- name: reason
        #  run: sh robot reason --reasoner {reasoner} --annotate-inferred-axioms true --input enanomapper-full.owl --output enanomapper-reasoned.owl
 # """)
        if keep_files == True:
          robot_yaml.write(f"""
  # Commit and push
        - name: Commit OWL files
          run: |
            {added_merged}
            {added_report}
            git config --local user.email "action@github.com"
            git config --local user.name "GitHub Action"
            git add enanomapper*
            git commit -m "{commit_message}" ./robot-report/* enanomapper*
            git push    
  """)
        robot_yaml.write(f"""
  # Upload artifacts
        - name: 'Upload eNanoMapper-full'
          uses: actions/upload-artifact@v3
          with:
            name: enanomapper-files
            path: enanomapper-*
        - name: 'Upload report'
          uses: actions/upload-artifact@v3
          with:
            name: report
            path: ./robot-report/* 
  """)

if __name__ == "__main__":
    main()
