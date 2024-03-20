#!/bin/bash

# Define the directory containing the internal OWL files
internal_dev="internal-dev"

# Extract all matches for the pattern <!-- http://purl.enanomapper.net/onto/ENM_\d\d\d\d\d\d\d -->
matches=$(grep -rhoP '<!-- http://purl.enanomapper.net/onto/ENM_\d{7} -->' "$internal_dev"/*.owl)

# Function to generate a random pattern
generate_random_pattern() {
    echo "http://purl.enanomapper.net/onto/ENM_$(shuf -i 1000000-9999999 -n 1)"
}

# Keep generating random patterns until a non-existing one is found
while true; do
    random_pattern=$(generate_random_pattern)

    # Check if the random pattern is not in the list of existing patterns
    if [[ ! $matches =~ $random_pattern ]]; then
        echo "$random_pattern" 
        break  # Exit the loop once a non-existing pattern is found
    fi
done
