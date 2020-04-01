#!/bin/bash 
# Author: @bugsam
# Date: 01/15/2018
#
#
# Changelog: 
#
#
# -----------------------------------------------------------------------
# Declaration of variables                                              |
# -----------------------------------------------------------------------
FILENAME=${0};
#COLOURS
RED="\033[0;31m"; #red color 
GREEN="\033[0;32m"; #green color
NC="\033[0m"; #no color
BOLD="\033[1m"; #bold

# -----------------------------------------------------------------------
# Declaration of variables: Dependencies				|
#									|
# fold									|
# -----------------------------------------------------------------------
DEPENDENCIES=(fold)

# -----------------------------------------------------------------------
# Log entries in ${LOG} file and print in screen                        |
# -----------------------------------------------------------------------
function func_log (){
EXITCODE="$2"
MESSAGE="$1"
DATE=$(date +"%h %d %T")
        if [ ${EXITCODE} -eq 0 ]
        then
                echo -e "[${GREEN} OK ${NC}] ${MESSAGE}"
                echo -e "${DATE} TWEETSTORM: STATUS: [ OK ] EXITCODE:${EXITCODE} ARGUMENT:${MESSAGE}" >> $FILENAME.log
        else
                echo -e "[${RED}FAIL${NC}] ${MESSAGE}"
                echo -e "${DATE} TWEETSTORM: STATUS: [FAIL] EXITCODE:${EXITCODE} ARGUMENT:${MESSAGE}" >> $FILENAME.log
                exit 1
        fi
}
# End of log function
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
# Check (Download Packages) dependecies
# -----------------------------------------------------------------------
function check_dependencies(){
for DEPENDENCE in "${DEPENDENCIES[@]}"
do
	MESSAGE="Checking dependence ${DEPENDENCE}"
	COMMAND=$(whereis -u $DEPENDENCE)
	if [ -n "${COMMAND}" ]
	then
		RESULT=0
	else
		RESULT=1

	fi
	func_log "${MESSAGE}" ${RESULT}
done
}
# -----------------------------------------------------------------------
# Function Usage
# -----------------------------------------------------------------------
function func_usage(){
echo -e "\t${BOLD}Tweetstorm Generator${NC}
        $FILENAME <options> \n
        -h | --help: print this help summary
	-c | --check-dependencies: check dependencies
	-l | --long-text: <tweetfilename> long text
        ${BOLD}EXAMPLES:${NC}
        $FILENAME -l /opt/hiring/longtweet.txt
	$FILENAME --long-text /opt/hiring/longtweet.txt
        "
        exit 1
}

# End of func_usage

# -----------------------------------------------------------------------
# Parse options
# -----------------------------------------------------------------------
ENTRIES=$(getopt -o "chl:"  -l "check-dependecies,help,long-text:" -n "${FILENAME}" -- "$@");

if [ "${?}" -ne 0 ];
then
        exit 1
fi
if [ ! "${#}" -gt 0 ]
then	
	func_usage
	exit
fi

eval set -- "${ENTRIES}"
while true; do
	case $1 in
		-c|--check-dependencies)
			shift
			check_dependencies
			exit
			;;

		-h|--help)
			shift
			func_usage
			;;
		-l|--long-text)	
			shift
			LONG_FILE=${1}
			shift
			;;
		--)	
			shift
			break
			;;
	esac
done	
# End of parse options

# -----------------------------------------------------------------------
# sanity check
# -----------------------------------------------------------------------
# check if $LONG_FILE is a regular file
if [ ! -f $LONG_FILE ]
then
        echo "$LONG_FILE ins't a regular file"
        exit 1
fi

# check if $LONG_FILE is greater than size zero
if [ ! -s $LONG_FILE ]
then
        echo "$LONG_FILE is empty"
        exit 1
fi

QUERY_FILE=$(file ${LONG_FILE})
echo $QUERY_FILE | grep -Eo "text" &> /dev/null
RESULT=$?
if [ $RESULT -ne 0 ]
then
        echo -e "$LONG_FILE not seens like a \"text file\""
        exit 1
fi

# -----------------------------------------------------------------------
# tweetstorm
# -----------------------------------------------------------------------

# store tweet
TEXT=$(fold -sw140 $LONG_FILE)

# count number of messages
MAX_LINE=$(echo "$TEXT[@]" | wc -l)

# start counter
COUNT=1

#write messages
while read TWEET;
do
	echo "$COUNT/$MAX_LINE $TWEET";
	let COUNT++
done <<< $TEXT
