import os
import re
import unittest
from collections import defaultdict


class UniqueIrisTest(unittest.TestCase):
    """
    Unit test for checking if the same exact string appears
    twice in the 'internal' and 'internal-dev' folders.
    """

    def test_duplicate_strings(self):
        """
        Test that the 'internal' and 'internal-dev' folders
        do not contain two instances of the same exact string.
        """
        pattern = r'<owl:Class rdf:about="http://purl.enanomapper.org/onto/ENM_\d+">'
        folders = ['internal', 'internal-dev']
        duplicates = defaultdict(list)

        for folder in folders:
            results = self._grep_directory(pattern, folder)
            for string, files in results.items():
                if len(files) > 1:
                    duplicates[folder].append((string, files))

        failure_messages = []
        for folder, dup_list in duplicates.items():
            failure_messages.append(f"Duplicate strings found in the '{folder}' folder:")
            for string, files in dup_list:
                failure_messages.append(f"\n- Duplicate: {string}\n  Files: {', '.join(files)}")

        self.assertFalse(duplicates, "\n".join(failure_messages))

    def _grep_directory(self, pattern, directory):
        """
        Recursively grep for the given pattern in the specified directory.
        Return a dictionary of matched strings and their corresponding files.
        """
        results = defaultdict(list)

        for root, _, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                with open(file_path, 'r') as f:
                    matches = re.findall(pattern, f.read())
                    for match in matches:
                        results[match].append(file_path)

        return results


if __name__ == '__main__':
    unittest.main()
