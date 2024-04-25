# Function to zip and optionally split files
gitzip() {
	# Parameters:
	# $1: Files to compress
	# $2: Chunk size (optional, default 80 MB)

	# Set chunk size with default value
	local chunk_size=${2:-99}
	local chunk_suffix="m"  # Suffix for MB

	# Check if a file or directory to compress was provided
	if [[ -z "$1" ]]; then
		echo "Error: No file or directory to compress specified."
		return 1
	fi

	# Compress and split files
	zip -s "${chunk_size}${chunk_suffix}" -r "output_file.zip" "$1"
	echo "Files have been compressed and split into ${chunk_size}MB chunks."
}

# Function to unzip split zip files
gitunzip() {
	# Parameter:
	# $1: Main zip file to start unzipping from

	# Check if zip file was provided
	if [[ -z "$1" ]]; then
		echo "Error: No zip file specified."
		return 1
	fi

	# Unzip files
	unzip "$1"
	echo "Files have been unzipped."
}
