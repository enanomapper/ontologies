import unittest
import re
import os
import yaml

class ConfigFilesTest(unittest.TestCase):
    """
    Unit test class for checking the integrity of config files.
    """
    def setUp(self):
        """Set up the configuration file path and the ontology repository path."""
        self.config_file = 'config.yaml'  # Path to the YAML configuration file
        self.repo_path = ''  # Path to the ontology repository

    def test_file_integrity(self):
        """
        Test case to check the integrity of eNM Ontology config files
        """
        directory = './config'
        blank_line = r'^[\s\r\n]*$'
        # REs for props file
        props_owl_pattern = r'^owl=http+'
        props_iris_pattern = r'^iris=.*$'
        props_slimmed_pattern = r'^slimmed=http+'
        # RE for iris file
        iris_pattern = r'[+-]?D?:?\(?(https?:\/\/[^)]+)\)?\s*.*$'
        config = self.load_configuration()
        # For each slim
        for slim in config['slims']:
            # Check props
            props_file = os.path.join(directory, slim + '.props')
            with open(props_file, 'r') as file:
                content = file.read()
                content_lines = content.splitlines()
                for i, line in enumerate(content_lines):
                    if i == 0:
                        self.assertRegex(line, props_owl_pattern, f"\nMisformatted slim URL: [{i+1}]:\t{line} (file: {props_file}")
                    if i == 1:
                        self.assertRegex(line, props_iris_pattern, f"\nMisformatted slim URL: [{i+1}]:\t{line} (file: {props_file}")
                    if i == 2:
                        self.assertRegex(line, props_slimmed_pattern, f"\nMisformatted slim URL: [{i+1}]:\t{line} (file: {props_file}")
                    if i > 2:
                        break
                file.close()

            # Check IRIs
            iris_file = os.path.join(directory, slim + '.iris')
            with open(iris_file, 'r') as file:
                content = file.read()
                for i, line in enumerate(content.splitlines()):
                    if re.search(blank_line, line):
                        pass
                    else:
                        match = re.search(iris_pattern, line)
                        self.assertRegex(line, iris_pattern, f"\nMisformatted URI: [{i+1}]{line} (file: {iris_file})")
                file.close()

    def load_configuration(self):
        """Load the configuration from the YAML file and return it as a dictionary."""
        with open(self.config_file, 'r') as config_file:
            config = yaml.safe_load(config_file)
        return config

if __name__ == '__main__':
    unittest.main()
