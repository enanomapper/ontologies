import os
import subprocess
import unittest
import yaml

class RobotTest(unittest.TestCase):
    """
    Unit test for checking whether the ontology has only the root class entity and its immediate subclasses are only anatomical entity, disposition, information content entity, material entity, process and quality.
    """
    def setUp(self):
        """Set up the configuration file path and the ontology repository path."""
        self.config_file = 'config.yaml'  # Path to the YAML configuration file
        
    def test_query_results(self):
        """
        Test the outcome  of robot query
        """
        config = self.load_configuration()
        robot_wrapper = config['robot']['robot-wrapper']
        robot_jar = config['robot']['robot-jar']
        # Run the command
        subprocess.run(["wget", "https://raw.githubusercontent.com/ontodev/robot/master/bin/robot"])
        subprocess.run(["wget", "https://github.com/ontodev/robot/releases/download/v1.9.0/robot.jar"])
        subprocess.run(["sh", "robot", "merge", "-i", "enanomapper.owl", "-o", "enanomapper-full.owl"])
        subprocess.run(["sh", "robot", "query", "--input", "enanomapper-full.owl", "--query", "scripts/src/tests/assets/test_root.sparql", "result"])
        subprocess.run(["cat", "result"])
        
        # Check the contents of the results file
        if os.stat('result').st_size==0:
            res = "passed"
        else:
            res= "failed"

            

        # Assert that the file contains only 'true'
        self.assertEqual(res, "passed")


    def load_configuration(self):
        """Load the configuration from the YAML file and return it as a dictionary."""
        
        with open(self.config_file, 'r') as config_file:
            config = yaml.safe_load(config_file)
        return config

if __name__ == '__main__':
    unittest.main()
