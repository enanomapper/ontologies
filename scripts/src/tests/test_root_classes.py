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
        subprocess.run(["wget", robot_wrapper])
        subprocess.run(["wget", robot_jar])
        subprocess.run(["sh", "robot", "merge", "-i", "enanomapper.owl", "-o", "enanomapper-full.owl"])
        subprocess.run(["sh", "robot", "query", "--input", "enanomapper-full.owl", "--query", "scripts/src/tests/assets/test_root.sparql", "result-root"])
        subprocess.run(["sh", "robot", "query", "--input", "enanomapper-full.owl", "--query", "scripts/src/tests/assets/test_entities.sparql", "result-entities"])
        subprocess.run(["cat", "result"])
        
        # Check the contents of the results files, fail or not fail
        if os.stat('result-root').st_size==0:
            res = "passed"
        else:
            res= "failed"

        if os.stat('result-root').st_size==0:
            res2 = "passed"
        else:
            res2= "failed"

            

        # Assert that the file was empty (no unexpected subclasses of entity)
        self.assertEqual(res, "passed", "Test failed: there is a root element other than entity (OBO:BFO_0000001)")
        self.assertEqual(res2, "passed",  "Test failed: please check which classes are under entity (OBO:BFO_0000001)")


    def load_configuration(self):
        """Load the configuration from the YAML file and return it as a dictionary."""
        
        with open(self.config_file, 'r') as config_file:
            config = yaml.safe_load(config_file)
        return config

if __name__ == '__main__':
    unittest.main()
