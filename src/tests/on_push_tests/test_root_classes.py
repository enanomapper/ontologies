import os
import subprocess
import unittest
import yaml

class RobotTest(unittest.TestCase):
    """Test class for checking ontology root class and its immediate subclasses."""

    def setUp(self):
        """Set up the configuration file path."""
        self.config_file = 'config.yaml'

    def test_query_results(self):
        """Test the outcome of robot query."""
        config = self.load_configuration()
        robot_wrapper = config['robot']['robot-wrapper']
        robot_jar = config['robot']['robot-jar']

        # Download necessary files
        self.download_file(robot_wrapper)
        self.download_file(robot_jar)

        # Run robot commands
        self.run_robot_command("merge", 
                               "-i", "enanomapper-dev.owl", 
                               "-o", "enanomapper-dev-full.owl")
        self.run_robot_command("query", 
                               "--input", "enanomapper-dev-full.owl", 
                               "--query", "src/tests/assets/test_root.sparql", 
                               "result-root")
        self.run_robot_command("query", 
                               "--input", "enanomapper-dev-full.owl", 
                               "--query", "src/tests/assets/test_entities.sparql", 
                               "result-entities")

        # Validate results
        self.validate_result('result-root', 
                             "Test failed: there is a root element other than entity (OBO:BFO_0000001)")
        self.validate_result('result-entities', 
                             "Test failed: please check which classes are under entity (OBO:BFO_0000001)")

    def download_file(self, url):
        """Download a file if it does not exist."""
        subprocess.run(["wget", "-nc", url])

    def run_robot_command(self, *args):
        """Run a robot command."""
        subprocess.run(["sh", "robot", *args])

    def validate_result(self, result_file, error_message):
        """Validate the result file is empty."""
        with open(result_file, 'r') as f:
            content = f.read()
        self.assertEqual(os.stat(result_file).st_size, 0,
                         f"{error_message}: {content}")

    def load_configuration(self):
        """Load the configuration from the YAML file."""
        with open(self.config_file, 'r') as config_file:
            return yaml.safe_load(config_file)


if __name__ == '__main__':
    unittest.main()
