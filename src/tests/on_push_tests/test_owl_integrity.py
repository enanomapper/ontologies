import unittest
import os
import yaml
from rdflib import Graph


class OWLIntegrityTest(unittest.TestCase):
    """Test class to check the integrity of the generated OWLs."""
    def setUp(self):
        self.config_file = 'config.yaml'
        self.repo_path = ''

    def test_owl_file_integrity(self):
        """Test case to check the integrity of OWL files."""
        config = self.load_configuration()
        self.check_files(config['slims'], '-ext.owl')
        self.check_files(config['props'], '-slim-prop.owl')
        self.check_files(config['versions'], 'enanomapper{}.owl', 
                         versioned=True)
        self.check_owl_files('internal')
        self.check_owl_files('internal-dev')

    def load_configuration(self):
        """Load the configuration from the YAML file and return it as a dictionary."""
        with open(self.config_file, 'r') as config_file:
            return yaml.safe_load(config_file)

    def is_owl_file_valid(self, file_path):
        """Check if the given OWL file is valid by parsing it."""
        try:
            Graph().parse(file_path, format='xml')
            return True
        except Exception as e:
            print(f"Error parsing OWL file: {file_path}\n{e}")
            return False

    def check_files(self, items, suffix, versioned=False):
        """Check if file paths are valid."""
        for item in items:
            for folder in ['external/', 'external-dev/']:
                file_path = os.path.join(self.repo_path, folder,
                                         item + suffix.format(item) 
                                         if versioned else item + suffix)
                self.assertTrue(self.is_owl_file_valid(file_path),
                                f"Invalid OWL file: {file_path}")

    def check_owl_files(self, folder):
        """Check if OWL files are valid."""
        for file in os.listdir(folder):
            if 'owl' in file.lower():
                file_path = os.path.join(self.repo_path, folder, file)
                self.assertTrue(self.is_owl_file_valid(file_path),
                                f"Invalid OWL file: {file_path}")


if __name__ == '__main__':
    unittest.main()
