#!/bin/bash

main_path=~/.burn_cd

if [[ ! -d $main_path ]]; then
  mkdir "$main_path";
fi

function __save_dir {
	printf "$(pwd)" > "$main_path/$1";
}

function bcd {
	while [[ $# > 0 ]]; do
		case "$1" in
			-r|--remove)
				dir_name="$2";
				if [[ -f "$main_path/$dir_name" ]]; then
					rm "$main_path/$dir_name";
				else
					echo "There is no such alias." 1>&2;
				fi

				shift 2;
				;;
			-l|--list)
				files=()
				while IFS= read -r -d '' file; do
					files+=("$file")
				done < <(find "$main_path" -maxdepth 1 -type f -printf "%f\0")

				file_index=1
				for file in "${files[@]}"; do
					printf "%d. %s - %s\n" "$file_index" "$file" "$(cat "$main_path/$file")"
					let "file_index++"
				done
				shift
				;;
			-s|--set)
				dir_name="$2";
				if [[ ! -e "$main_path/$dir_name" ]]; then
					__save_dir "$dir_name";
				else
					print "You already have directory with this name. Do you want to reset it?(y/n) ";
					read -r reset
					if [[ $reset == 'y' ]]; then
						__save_dir $dir_name
					fi
				fi
				shift 2;
				break;
				;;
			-*)
				echo "Unknown argument: $1" 1>&2;
				exit 1;
				;;
			*)
				if [[ -f "$main_path/$1" ]]; then
					target_dir="$(cat "$main_path/$1")"
					cd "$target_dir"
				else
					echo 'There is no saved directory with this name.' 1>&2;
					exit 1;
				fi
				shift;
				;;
		esac
	done

	return 0;
}
