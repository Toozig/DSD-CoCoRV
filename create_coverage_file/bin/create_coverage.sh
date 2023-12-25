#!/bin/bash

##### usage #####

print_usage() {
    echo "Usage: $0 -g <gnomAD Coverage file> -c <chrom> -o <output file> [-t <tmp folder>] [-d <segment merge distance>]"
    exit 1
}

##### functions #####

# Function to check if a file exists
file_exists() {
    [ -e "$1" ]
}

# Function to generate a new file name by appending a number
generate_new_name() {
    local base_name="$1"
    local count=0

    while file_exists "${base_name}_${count}"; do
        ((count++))
    done

    echo "${base_name}_${count}"
}

########### script #############

# Parse command-line arguments
while getopts ":g:c:o:t:d:" opt; do
    case $opt in
        g) gnomADCoverage="$OPTARG" ;;
        c) chrom="$OPTARG" ;;
        o) outputFile="$OPTARG" ;;
        t) tmpFolder="$OPTARG" ;;
        d) mergeDistance="$OPTARG";;
        \?) echo "Invalid option: -$OPTARG" >&2; print_usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; print_usage ;;
    esac
done

# Check if required arguments are provided
if [ -z "$gnomADCoverage" ] || [ -z "$chrom" ] || [ -z "$outputFile" ]; then
    echo "Error: Missing required arguments."
    print_usage
fi

# Set default tmpFolder if not provided
if [ -z "$tmpFolder" ]; then
    tmpFolder="~/tmp"
fi

# Set default tmpFolder if not provided
if [ -z "$mergeDistance" ]; then
    mergeDistance="1"
fi

### create log file ##

# Extract the filename and extension
filename=$(basename "$outputFile")
extension="${filename##*.}"

# Replace the extension with ".log"
newFilename="${filename%.*}.log"

# Construct the new file path
logFileName="$(dirname "$outputFile")/$newFilename"



if file_exists "$input_file"; then
	logFile=$(generate_new_name "$logFileName")

else
	logFile=${logFileName}
    fi

touch logFile


echo "log file - $logFile"

echo -e "#### Log of $(basename $0) for $chrom ####" \
"\nDate: $(date +"%Y-%m-%d")" \
"\nTime: $(date +"%H:%M:%S")" \
"\n\n ## arguments ##" \
"\ngnomAD Coverage file: $gnomADCoverage" \
"\nchromosome: $chrom" \
"\noutput file: $outputFile" \
"\ntmp Folder: ${tmpFolder}\n" >> $logFile


# Echo the command and its arguments to the log file
echo -e "$(date +"%Y-%m-%d %H:%M:%S") Running:\n $0 $@" >> "$logFile"

zcat ${gnomADCoverage} | \
  grep "${chrom}:" |
  awk -F'\t' '(NR > 1 && $7 >= 0.9) {split($1, a, "[:-]"); printf "%s\t%d\t%d\n", a[1], a[2]-1, a[2]}' | \
  sort -T $tmpFolder -k1,1 -k2,2n | \
  sed 's/ /\t/g' | \
  bedtools merge -d $mergeDistance -i stdin 2>> $logFile | \
  gzip > ${outputFile}


# echo the exit code
echo "$(date +"%Y-%m-%d %H:%M:%S") Exit Status: $?" >> "$logFile"

echo "Done $0"
