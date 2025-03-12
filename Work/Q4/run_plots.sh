#!/bin/bash

# Check if the user provided a file as a parameter
if [[ -z "$1" ]]; then
    echo "⚠️  Error: You must provide the path to the CSV file."
    echo "Usage: $0 <path_to_csv>"
    exit 1
fi

CSV_FILE="$1"

# Check if the file exists
if [[ ! -f "$CSV_FILE" ]]; then
    echo "⚠️  Error: The file '$CSV_FILE' was not found."
    exit 1
fi

# Variable to track if there were any errors
all_successful=true

# Create the Diagrams directory if it doesn't exist
if [[ ! -d "Diagrams" ]]; then
    mkdir -p "Diagrams"
    echo "Created Diagrams directory."
else
    echo "Diagrams directory already exists."
fi

# Read the CSV file, skipping the header row
tail -n +2 "$CSV_FILE" | while IFS=, read -r plant height leaf_count dry_weight; do
    # Remove quotes
    height=$(echo "$height" | tr -d '"')
    leaf_count=$(echo "$leaf_count" | tr -d '"')
    dry_weight=$(echo "$dry_weight" | tr -d '"')

    # Check for empty fields
    if [[ -z "$plant" || -z "$height" || -z "$leaf_count" || -z "$dry_weight" ]]; then
        echo "⚠️  Error: Missing field for $plant, skipping..."
        all_successful=false
        continue
    fi

    # Convert lists to numbers
    height_list=($(echo "$height" | tr '-' ' '))
    leaf_count_list=($(echo "$leaf_count" | tr '-' ' '))
    dry_weight_list=($(echo "$dry_weight" | tr '-' ' '))

    # Check if all lists contain only numbers
    for num in "${height_list[@]}" "${leaf_count_list[@]}" "${dry_weight_list[@]}"; do
        if ! [[ "$num" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            echo "⚠️  Error: Invalid data for $plant ($num), skipping..."
            all_successful=false
            continue 2
        fi
    done

    # Check if the plant directory already exists inside Diagrams
    if [[ -d "Diagrams/$plant" ]]; then
        echo "Directory for $plant already exists in Diagrams, skipping Python script."
        continue
    fi

    # Create plant directory if it doesn't exist
    if [[ ! -d "$plant" ]]; then
        mkdir -p "$plant"
        echo "Created directory for $plant."
    else
        echo "Directory for $plant already exists."
    fi

    # Run the Python script with the parsed data
    python3 ../Q2/plant_plots.py --plant "$plant" --height "${height_list[@]}" --leaf_count "${leaf_count_list[@]}" --dry_weight "${dry_weight_list[@]}"

    # Check if the Python script executed successfully
    if [[ $? -ne 0 ]]; then
        echo "⚠️  Error: Python script failed for $plant, skipping..."
        all_successful=false
        continue
    fi

    # Check if the images exist before moving them
    if [[ -f "${plant}_scatter.png" ]]; then
        mv "${plant}_scatter.png" "${plant}/"
    fi
    if [[ -f "${plant}_histogram.png" ]]; then
        mv "${plant}_histogram.png" "${plant}/"
    fi
    if [[ -f "${plant}_line_plot.png" ]]; then
        mv "${plant}_line_plot.png" "${plant}/"
    fi

    # Move the plant directory into the Diagrams directory
    mv "$plant" "Diagrams/"

done

# Final check to print if all executions were successful
if $all_successful; then
    echo "✅  All Python script executions were successful."
else
    echo "⚠️  Some Python script executions failed."
fi
