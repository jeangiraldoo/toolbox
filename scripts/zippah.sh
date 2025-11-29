#!/bin/bash

# Description: Zips the contents of a directory into a target path if
# 	the number of files exceeds a threshold, else it just moves the content
# Use case: For example, if you need to upload several files to a
# 	service that only accepts one file per submission, running this
# 	script will automatically bundle them into a single ZIP archive.
# Author: Jean Giraldo
# License: MIT

shopt -s globstar
script_name=$(basename "$0")
dir_name="$(basename "$PWD")"

TARGET_DIR="$HOME"
FILE_NUMBER_THRESHOLD=1
IGNORED_FILES=("venv" ".venv" "__pycache__" "*.egg-info*" "build")

num_items_current_dir=$(find . -mindepth 1 -maxdepth 1 | wc -l)

echo "[Settings]"
echo "Directory: $dir_name"
echo "Target: $TARGET_DIR"
echo "Treshold: $FILE_NUMBER_THRESHOLD"
echo -e "Total files: $num_items_current_dir\n"

[ "$num_items_current_dir" -gt "$FILE_NUMBER_THRESHOLD" ] && action="zip" || action="move"

echo "[Action]"
echo -e "$action\n"
echo "[Logs]"

included_items=()
for raw_relative_file_path in ./**; do
	simple_relative_file_path=${raw_relative_file_path#./}
	should_ignore_file=false
	for a in "${IGNORED_FILES[@]}"; do
		if [[ "$simple_relative_file_path" == $a || "$simple_relative_file_path" == $a/* ]]; then
			should_ignore_file=true
			break
		fi
	done

	if [[ "$should_ignore_file" == false ]]; then
		included_items+=("$simple_relative_file_path")
	fi
done

if [[ $action == "zip" ]]; then
	zip "$TARGET_DIR/$dir_name.zip" "${included_items[@]}"
	exit
fi

for item in "$included_items"; do
	cp $item "$TARGET_DIR"
done
