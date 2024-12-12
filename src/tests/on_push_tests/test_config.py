import unittest
import re
import os
import yaml

class ConfigFilesTest(unittest.TestCase):
    """Test class for checking the integrity of config files."""

    def setUp(self):
        """Set up the configuration file path and the ontology repository path."""
        self.config_file = 'config.yaml'
        self.repo_path = ''
        self.directory = './config'
        self.blank_line = r'^[\s\r\n]*$'
        self.props_patterns = [
            r'^owl=http+',
            r'^iris=.*$',
            r'^slimmed=http+'
        ]
        self.iris_pattern = r'[+-]?D?:?\(?(https?:\/\/[^)]+)\)?\s*.*$'

    def test_file_integrity(self):
        """Test case to check the integrity of eNM Ontology config files."""
        config = self.load_configuration()
        for slim in config['slims']:
            self.check_props_file(slim)
            self.check_iris_file(slim)

    def check_props_file(self, slim):
        """Check the props file for the given slim."""
        props_file = os.path.join(self.directory, f'{slim}.props')
        with open(props_file, 'r') as file:
            for i, line in enumerate(file):
                if i < len(self.props_patterns):
                    self.assertRegex(line, self.props_patterns[i], f"\nMisformatted slim URL: [{i+1}]:\t{line} (file: {props_file})")
                else:
                    break

    def check_iris_file(self, slim):
        """Check the iris file for the given slim."""
        iris_file = os.path.join(self.directory, f'{slim}.iris')
        with open(iris_file, 'r') as file:
            for i, line in enumerate(file):
                if not re.search(self.blank_line, line):
                    self.assertRegex(line, self.iris_pattern, f"\nMisformatted URI: [{i+1}]{line} (file: {iris_file})")

    def load_configuration(self):
        """Load the configuration from the YAML file and return it as a dictionary."""
        with open(self.config_file, 'r') as config_file:
            return yaml.safe_load(config_file)


if __name__ == '__main__':
    unittest.main()
