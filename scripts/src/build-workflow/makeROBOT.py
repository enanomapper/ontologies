#!/usr/local/bin/python
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
    commit_message = config["robot-commands"]["commit-message"]
    reason = config["robot-commands"]["reason"]["value"]
    reasoner = config["robot-commands"]["reason"]["reasoner"]
    added_merged = ""
    with open("../../../.github/workflows/robot.yml", "a+") as robot_yaml:
        robot_yaml.truncate(0)
        robot_yaml.write("""name: ROBOT-commands
on:
    {}
    schedule:
    - cron: "1 * * 1-12 *"
jobs:
    robot-workflows:
        runs-on: ubuntu-latest
        steps:
        - name: checkout repo
          uses: actions/checkout@v2
        - name: get robot
          run: |
            ls
            wget {}
            wget {}
            chmod 777 robo*
    """.format(dispatch, robot, robot_jar))
        if merge == True:
            robot_yaml.write("""
        - name: merge
          run: sh robot merge -i enanomapper.owl -o enanomapper-full-temp.owl""")
            added_merged = "git add enanomapper-full.owl"
        if verify == True:
            pass
        if report == True:
            robot_yaml.write("""
        - name: report
          run: sh robot report --fail-on none -i enanomapper-full-temp.owl -o robot-report/report.tsv
        - name: diff
          run: |
            sh robot diff --left enanomapper-full.owl --right enanomapper-full-temp.owl --output robot-report/diff.txt
            rm enanomapper-full.owl
            mv enanomapper-full-temp.owl enanomapper-full.owl""")
            added_report = "git add ./robot-report/*"
        if validate == True:
            pass # to be added
        if odk_dashboard == True:
            pass # to be added
        if reason == True and reasoner in ["ELK", "hermit", "jfact", "whelk"]:
          robot_yaml.write("""
        - name: reason
          run: sh robot reason --reasoner {} --annotate-inferred-axioms true --input enanomapper-full.owl --output enanomapper-reasoned.owl
  """.format(reasoner))

        robot_yaml.write("""
  # Commit and push
        - name: Commit OWL files
          run: |
            {}
            {}
            git config --local user.email "action@github.com"
            git config --local user.name "GitHub Action"
            git commit -m "{}" ./robot-report/* enanomapper*
        - name: Push changes
          uses: ad-m/github-push-action@master
          with:
            github_token: ${{ secrets.GITHUB_TOKEN }}
            branch: master   
  """.format(added_merged, added_report, commit_message))

if __name__ == "__main__":
    main()