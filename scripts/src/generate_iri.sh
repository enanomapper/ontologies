#!/bin/bash

# Define the directory containing the internal OWL files
internal_dev="internal-dev"

# Function to generate a 7-digit hash based on current datetime
generate_hash() {
    current_datetime=$(date +"%Y%m%d%H%M%S")  # Get current date and time
    hash=$(echo -n "$current_datetime" | sha1sum | awk '{print $1}')  # Calculate SHA1 hash
    hash_digits=$(echo "$hash" | tr -dc '0-9' | cut -c 1-7)  # Extract first 7 digits
    echo "$hash_digits"
}

# Keep generating random patterns until a non-existing one is found
while true; do
    random_hash=$(generate_hash)
    random_pattern="http://purl.enanomapper.net/onto/ENM_$random_hash"

    # Check if the random pattern is not in the list of existing patterns
    if ! grep -qF "$random_pattern" "$internal_dev"/*.owl; then
        echo "$random_pattern"
        break  # Exit the loop once a non-existing pattern is found
    fi
done
