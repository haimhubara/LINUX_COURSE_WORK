#!/bin/bash

# Default output directory
output_dir="Diagrams"
create_tar=false  # Flag to create tar.gz
destination_dir=""

# Parse command-line arguments
while getopts "o: t d:" opt; do
    case $opt in
        o)
            output_dir="$OPTARG"
            ;;
        t)
            create_tar=true  # Set flag to create tar.gz file
            ;;
        d)
            destination_dir="$OPTARG"  # Set destination directory for the tar.gz file
            ;;
        *)
            echo "Usage: $0 [-o output_dir] [-t] [-d destination_dir] <path_to_csv>"
            exit 1
            ;;
    esac
done

# Check if the user provided a file as a parameter (after parsing flags)
shift $((OPTIND - 1))
if [[ -z "$1" ]]; then
    echo "⚠️  Error: You must provide the path to the CSV file."
    echo "Usage: $0 [-o output_dir] [-t] [-d destination_dir] <path_to_csv>"
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

# Create the output directory if it doesn't exist
if [[ ! -d "$output_dir" ]]; then
    mkdir -p "$output_dir"
    echo "Created output directory: $output_dir."
else
    echo "Output directory '$output_dir' already exists."
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

    # Create the plant directory inside the specified output directory
    plant_output_dir="$output_dir/$plant"
    if [[ ! -d "$plant_output_dir" ]]; then
        mkdir -p "$plant_output_dir"
        echo "Created directory for $plant in $output_dir."
    else
        echo "Directory for $plant already exists, skipping directory creation."
    fi

    # Run the Python script with the parsed data
    python3 ../Q2/plant_plots.py --plant "$plant" --height "${height_list[@]}" --leaf_count "${leaf_count_list[@]}" --dry_weight "${dry_weight_list[@]}"
    if [[ $? -ne 0 ]]; then
        echo "⚠️  Error: Python script failed for $plant, skipping..."
        all_successful=false
        continue
    fi

    # Move the graphs into the output directory
    if [[ -f "${plant}_scatter.png" ]]; then
        mv "${plant}_scatter.png" "$plant_output_dir/"
    fi
    if [[ -f "${plant}_histogram.png" ]]; then
        mv "${plant}_histogram.png" "$plant_output_dir/"
    fi
    if [[ -f "${plant}_line_plot.png" ]]; then
        mv "${plant}_line_plot.png" "$plant_output_dir/"
    fi

done

# Final check to print if all executions were successful
if $all_successful; then
    echo "✅  All Python script executions were successful."
else
    echo "⚠️  Some Python script executions failed."
fi

# Get the current date and time in the format YYYY-MM-DD_HH-MM-SS
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Create the tar.gz file with the timestamp as the name
if $create_tar; then
    tar -czf "$timestamp.tar.gz" "$output_dir"
    if [[ $? -eq 0 ]]; then
        echo "✅  Created tar.gz file: $timestamp.tar.gz"
    else
        echo "⚠️  Error: Failed to create tar.gz file."
    fi
fi

# If destination directory is provided, move the tar.gz file there
if [[ -n "$destination_dir" ]]; then
    if [[ -d "$destination_dir" ]]; then
        mv "$timestamp.tar.gz" "$destination_dir/"
        echo "✅  Moved tar.gz file to $destination_dir."
    else
        echo "⚠️  Error: Destination directory '$destination_dir' does not exist."
    fi
fi
