#!/usr/bin/env bash

# bash script for creating path shortcuts in terminal
# Copyright (C) 2017 Lars Andre Landås <landas@gmail.com>
# Distributed under the GNU General Public License, version 3.0.

# For usage type cdd in terminal after you have sourced this file
# Includes auto-complete support
# Mac fix: edit line stating with "sed -i ..." to "sed -i '' ..."

if [ ! -f ~/.cdd ]; then
    touch ~/.cdd
fi

cdd () {
	
	cdd_array=() # Create array
	while IFS= read -r line # Read a line
	do
		cdd_array+=("$line") # Append line to the array
	done < ~/.cdd

	remove () {
		echo "Removing $1 if exists in ~/.cdd"
		sed -i "/^$1 /d" ~/.cdd
	}

	if [[ $1 = "add" ]] && [[ ! $2 = "" ]]; then
		remove $2
		echo "$2 $3" >> ~/.cdd
		echo "Added $2 $3 to ~/.cdd"
		return
	fi

	if [[ $1 = "remove" ]]; then
		remove $2
		return
	fi

	if [[ $1 = "list" ]] && [[ $2 = "-v" ]]; then
		sort ~/.cdd
		return
	fi


	if [[ $1 = "list" ]]; then
		b=($(for l in "${cdd_array[@]}"; do echo "$l"|cut -d' ' -f1; done | sort))

		for l in "${b[@]}"; do 
			printf "%-8s\n" "${l}"
		done | column	
		
		return
	fi

	for line in "${cdd_array[@]}"
	do
		thea=($line)
		IFS=' ' read -r id path <<< "$line"
		if [[ $1 == ${id} ]]; then
			eval cd "'${path}'"
			return
		fi
	done

	if [[ ! $1 == "" ]]; then
		echo -e "\e[91m\e[1mError:\e[21m\e[39m $1 is not a shortcut"
	fi

	echo -e "\e[1mUsage:\e[21m cdd <shortcut> | add <shortcut> path | remove <shortcut> | list [-v]"
}

_cdd() {
	local cur cdd_array cdd_args thea
	
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=()
	cdd_array=() # Create array
	cdd_args=""
	while IFS= read -r line # Read a line
	do
		cdd_array+=("$line") # Append line to the array
		thea=($line)
		cdd_args="$cdd_args ${thea[0]}"
	done < ~/.cdd

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $(compgen -W "$cdd_args" -- $cur) )
	elif [ $COMP_CWORD -eq 2 ]; then
		case "${COMP_WORDS[COMP_CWORD-1]}" in
			"remove")
				COMPREPLY=( $(compgen -W "$cdd_args" -- $cur) )
				;;
			"add")
				COMPREPLY=( $(compgen -f -- $cur) )
				;;
		esac
	elif [ $COMP_CWORD -eq 3 ]; then
		case "${COMP_WORDS[COMP_CWORD-2]}" in
			"add")
				_filedir
				;;
		esac
	fi
	return 0
}

complete -F _cdd cdd
