import unittest
import os
import yaml
from rdflib import Graph
import filecmp

class AreModulesUpdated(unittest.TestCase):
    """Unit test class to check whether the external and internal modules have been updated with the latest dveelopment versions before making a release."""
    
    def setUp(self):
        """Set up the configuration file path and the ontology repository path."""
        self.config_file = 'config.yaml'  # Path to the YAML configuration file
        self.repo_path = ''  # Path to the ontology repository

    def test_diff(self):
        """Test case to check the diff between dev and release modules"""
        config = self.load_configuration()
        # Check slims
        for slim in config['slims']:
            slim = slim + '-slim.owl'
            self.assertTrue(self.is_updated(directory='external', file =slim), f"\n\nEXPLANATION: Need to update module external/{slim}. Please check the rest too.")
        # Check props
        for prop in config['props']:
            prop = prop + '-slim-prop.owl'
            self.assertTrue(self.is_updated(directory='external', file =prop), f"\n\nEXPLANATION: Need to update module external/{slim}. Please check the rest too.")
        # Check internal OWLs
        internal = os.listdir('internal')
        for i in internal:
            if 'OWL'.casefold() in i:
                self.assertTrue(self.is_updated(directory='internal', file=i), f"\n\nEXPLANATION: Need to update module internal/{i}. Please check the rest too.")
    def load_configuration(self):
        """Load the configuration from the YAML file and return it as a dictionary."""
        
        with open(self.config_file, 'r') as config_file:
            config = yaml.safe_load(config_file)
        return config

    def is_updated(self, directory, file):
        """
        Check if the given release module OWL file is updated with the latest
        dev version.

        Returns:
            bool: True if the file is valid, False otherwise.
        """
        file_path = os.path.join(directory, file)
        directory_dev = directory+'-dev'
        dev_file_path = os.path.join(directory_dev, file)
        return filecmp.cmp(file_path, dev_file_path)
        



if __name__ == '__main__':
    unittest.main()
