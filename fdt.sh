#!/bin/bash

# Function to apply patches using fdtput
apply_fdt_patch() {
  # apply_fdt_patch <dtb_img> <fdt_patch_file>
  [ -f "$2" ] || { echo "Error: Can not found fdt patch file: $2!" ; return 1; }
  cat $2 | sed -e 's/[  ]*#.*//' -e '/^[        ]*$/d' | while read line; do
    ${bin} $1 $line || { echo "Error: Failed to apply fdt patch: $2" ; return 1; }
  done
}

# Check if required tools are available
bin="$(command -v fdtput)"
if [ -z "$bin" ]; then
  echo "Error: fdtput command not found. Please install it first."
  exit 1
fi

# Usage: apply_fdt_patch_script <dtb_img> <fdt_patch_file1> [<fdt_patch_file2> ...]
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <dtb_img> <fdt_patch_file1> [<fdt_patch_file2> ...]"
  exit 1
fi

dtb_img="$1"
shift

for patch_file in "$@"; do
  echo "Applying patch: $patch_file"
  apply_fdt_patch "$dtb_img" "$patch_file"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to apply patch: $patch_file"
    exit 1
  fi
done

echo "All patches applied successfully!"
