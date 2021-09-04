#!/bin/bash

function cryptME_crypt()
{
	openssl enc -aes-256-cbc -salt -in "$1" -out "$1$EXT" -k $PASS 2> /dev/null
	rm "$1" 2> /dev/null # remove original file
	if [ "$VERBOSE" = "on" ]; then
		echo "$1 is crypted ... new file called $1$EXT"
	fi
}

function cryptME_decrypt()
{
	if [[ $1 = *$EXT ]]; then
    	name=$(echo $1 | awk '{print $1}' FS="$EXT")
	  	openssl enc -aes-256-cbc -d -in "$1" -out "$name" -k $PASS 2> /dev/null
  		rm "$1" 2> /dev/null # remove crypt file
  	fi
  	if [ "$VERBOSE" = "on" ]; then
		echo "$1 is decrypted ... new file called $name"
	fi
}

function cryptME_walk() # recursive walk on targets
{
    for files in $1; do
    if [ -d "$files" -a ! -L "$files" ]; then
    	cryptME_walk "$files/*"
    elif [[ $files = *cryptME.sh ]] || [[ $files = *preset2.sh ]]; then # dont crypt this file!
      	continue
    elif [ -f "$files" ]; then
    	if [ "$MODE" = "crypt" ]; then # crypt file
      		cryptME_crypt "$files"
      	fi
      	if [ "$MODE" = "decrypt" ]; then # decrypt file
      		cryptME_decrypt "$files"
      	fi
    fi
  done
}

function cryptME_usage() # help
{
	echo "usage: cryptME -[c|d] -v file[s]"
	echo "-c for crypt file[s]"
	echo "-d for decrypt file[s]"
	echo "-v for verbose mode"
	echo "-h for this help"
	echo "-a for crypt|decrypt all files in directory (recursive)"
}

function cryptME()
{
	OPTIND=1
	PASS="" # password for crypt|decrypt
	DIR="" # work directory | targets
	EXT=".ENC" # just end of filename
	MODE="" # flag for crypt or decrypt
	OPT="no" # flag for 
	ALL="no" # flag for recursive (all files in directory)
	VERBOSE="off" # flag for verbose
	_default_dir=$(pwd)/* # default DIR is pwd (for recursive walk)
	_default_pass=max # default password
	while getopts :cdvah option # flags (see in function usage)
	do
		case $option in
			c) MODE="crypt"
			   OPT=yes
			   ;;
			d) MODE="decrypt"
			   OPT=yes
			   ;;
			v) VERBOSE=on
			   ;;
			a) ALL=yes # cryptME -[c|d] -a | crypt -[c|d] *
			   ;;
			h) cryptME_usage
				return 1
				;;
		esac
	done
	echo "$ALL" 
	shift $(expr $OPTIND - 1) # shift all flags
	if [ "$ALL" = "no" ] && [ $# -eq 0 ] || [ "$OPT" = "no" ]; then
		cryptME_usage >&2
		echo "HERE"
		return 1
	fi
	DIR=$@ # get targets
	: ${DIR:=$_default_dir} # if DIR is empty -> default
	echo "mode: $MODE | target(s): $DIR" # inform
	read -p "enter password (max): " PASS # read PASS
	: ${PASS:=$_default_pass} # if PASS is empty -> default
	cryptME_walk "$DIR"
}

#cryptME -d -a
#cryptME -d -a