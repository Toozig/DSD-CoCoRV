#!/bin/bash

# Check if bedtools is installed
if ! command -v bedtools &> /dev/null; then
    echo "Error: bedtools is not installed. Please install bedtools before running this script."
    exit 1
fi

# Check if at least two BED files are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [-s] <bedfile1.bed> <bedfile2.bed> [<bedfile3.bed> ...] -o <outputfile.bed>"
    exit 1
fi

# Parse command-line arguments
input_files=()
output_file=""
sorted_flag=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        -o|--output)
            shift
            output_file="$1"
            shift
            ;;
        -s|--sorted)
            sorted_flag=true
            shift
            ;;
        *)
            input_files+=("$1")
            shift
            ;;
    esac
done

# Check if output file is provided
if [ -z "$output_file" ]; then
    echo "Error: Output file not specified. Use -o <outputfile.bed>"
    exit 1
fi

# Check if input files exist
for file in "${input_files[@]}"; do
    if [ ! -e "$file" ]; then
        echo "Error: File $file not found."
        exit 1
    fi
done

# Sort input files by name if the -s flag is provided
if [ "$sorted_flag" = true ]; then
    input_files=($(printf "%s\n" "${input_files[@]}" | sort))
fi

# Use bedtools to concatenate the BED files
bedtools cat -i "${input_files[@]}" > "$output_file"

echo "Concatenation completed. Output saved to: $output_file"
