#!/bin/bash

# Check for two arguments
if [ $# -ne 2 ]; then
  echo "Error: Please provide two branch names (base branch and modified branch)."
  exit 1
fi

# Get the base and modified branch names
base_branch="$1"
modified_branch="$2"

# Generate current epoch time
epoch_time=$(date +%s)

# Generate patch file name
patch_filename="patch_${epoch_time}.patch"

# Generate git patch
git diff --binary $base_branch $modified_branch >> "$patch_filename"

# Check if patch file was created
if [ ! -f "$patch_filename" ]; then
  echo "Error: Failed to generate patch file."
  exit 1
fi

# Upload patch file to bashupload.com
upload_output=$(curl bashupload.com -T "$patch_filename" 2>&1)

# Check for upload errors
if [[ $upload_output == *"error"* ]]; then
  echo "Error: Failed to upload patch file to bashupload.com."
  exit 1
fi

# Extract the download link from the output
download_cmd=$(grep 'wget' <<< "$upload_output")


# Run build
crave run --no-patch -- "git reset --hard && \
git checkout $1 && \
git reset --hard && \
git clean -fdx && \
$download_cmd -c -O ready.patch && \
git apply ready.patch && \
./build.sh tulip
"
