import unittest
import os
import yaml
from rdflib import Graph


class OWLIntegrityTest(unittest.TestCase):
    """Unit test class to check the integrity of OWL files in an ontology repository."""
    
    def setUp(self):
        """Set up the configuration file path and the ontology repository path."""
        self.config_file = 'config.yaml'  # Path to the YAML configuration file
        self.repo_path = ''  # Path to the ontology repository

    def test_owl_file_integrity(self):
        """Test case to check the integrity of OWL files."""
        config = self.load_configuration()
        # Check slims
        for slim in config['slims']:
            for folder_path in [self.repo_path+'external/', self.repo_path+'external-dev/']:
                file_path = os.path.join(folder_path, slim+'-slim.owl')
                self.assertTrue(self.is_owl_file_valid(file_path), f"Invalid slims OWL file: {file_path}")
        # Check props
        for prop in config['props']:
            for folder_path in [self.repo_path+'external/', self.repo_path+'external-dev/']:
                file_path = os.path.join(folder_path, prop+'-slim-prop.owl')
                self.assertTrue(self.is_owl_file_valid(file_path), f"Invalid props OWL file: {file_path}")
        # Check eNanoMapper OWLs
        for version in config['versions']:
            file = os.path.join(self.repo_path, f'enanomapper{version}.owl')
            self.assertTrue(self.is_owl_file_valid(file), f"Invalid eNanoMapper ontology OWL file: enanomapper{version}.owl")
        internal = os.listdir('internal')
        internal_dev = os.listdir('internal-dev')
        for i in internal:
            if 'OWL'.casefold() in i:
                file = os.path.join(self.repo_path, 'internal', i)
                self.assertTrue(self.is_owl_file_valid(file), f"Invalid eNanoMapper internal module OWL file: {i}")
        for i in internal_dev:
            if 'OWL'.casefold() in i:
                file = os.path.join(self.repo_path, 'internal-dev', i)
                self.assertTrue(self.is_owl_file_valid(file), f"Invalid eNanoMapper internal-dev module OWL file: {i}")
    def load_configuration(self):
        """Load the configuration from the YAML file and return it as a dictionary."""
        
        with open(self.config_file, 'r') as config_file:
            config = yaml.safe_load(config_file)
        return config

    def is_owl_file_valid(self, file_path):
        """
        Check if the given OWL file is valid by parsing it.

        Returns:
            bool: True if the file is valid, False otherwise.
        """
        
        try:
            graph = Graph()
            graph.parse(file_path, format='xml')
            return True
        except Exception as e:
            print(f"Error parsing OWL file: {file_path}\n{e}")
            return False



if __name__ == '__main__':
    unittest.main()
