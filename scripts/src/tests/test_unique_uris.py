import os
import re
import unittest


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

        # Search for the pattern in the 'internal' folder
        internal_results = self._grep_directory(pattern, '../../../internal')

        # Search for the pattern in the 'internal-dev' folder
        internal_dev_results = self._grep_directory(pattern, '../../../internal-dev')

        # Check for duplicate strings in each folder
        internal_duplicates = self._find_duplicates(internal_results)
        internal_dev_duplicates = self._find_duplicates(internal_dev_results)

        # Prepare failure messages with filenames
        failure_messages = []
        if internal_duplicates:
            failure_messages.append(f"Duplicate strings found in the 'internal' folder in the following files:")
            for duplicate in internal_duplicates:
                duplicate_files = self._find_files_with_string(duplicate, '../../../internal')
                failure_messages.append(f"\n- Duplicate: {duplicate}\n  Files: {', '.join(duplicate_files)}")
        if internal_dev_duplicates:
            failure_messages.append(f"Duplicate strings found in the 'internal-dev' folder in the following files:")
            for duplicate in internal_dev_duplicates:
                duplicate_files = self._find_files_with_string(duplicate, '../../../internal-dev')
                failure_messages.append(f"\n- Duplicate: {duplicate}\n  Files: {', '.join(duplicate_files)}")

        # Assert that there are no duplicate strings in either folder
        self.assertFalse(internal_duplicates, "\n".join(failure_messages))

    def _grep_directory(self, pattern, directory):
        """
        Recursively grep for the given pattern in the specified directory.
        Return a list of matched strings.
        """
        results = []

        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)

                with open(file_path, 'r') as f:
                    file_contents = f.read()
                    matches = re.findall(pattern, file_contents)
                    results.extend(matches)

        return results

    def _find_duplicates(self, lst):
        """
        Find duplicate strings in the given list.
        Return a list of duplicate strings.
        """
        duplicates = []
        seen = set()

        for item in lst:
            if item in seen and item not in duplicates:
                duplicates.append(item)
            else:
                seen.add(item)

        return duplicates

    def _find_files_with_string(self, string, directory):
        """
        Find files within the specified directory that contain the given string.
        Return a list of file names.
        """
        matching_files = []

        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)

                with open(file_path, 'r') as f:
                    file_contents = f.read()
                    if string in file_contents:
                        matching_files.append(file_path)

        return matching_files


if __name__ == '__main__':
    unittest.main()
