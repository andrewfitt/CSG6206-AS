#!/bin/bash

declare -g db_location="./imageSizes.db"

declare -g fileLocation=""


#---------- Functions -------------

function initDB(){
	if [ ! -f $db_location ]; then
		#if the db file doesnt exist, create the table which automatically creates the db file first
		sqlite3 $db_location "create table filesAndSizes(filename TEXT PRIMARY KEY, filesize INTEGER);"
		if [[ $? -ne 0 ]]; then
			#if the table creation fails, the script exits with the sqlite error level
			exit $?
		fi
	fi
}


function insertDBRecord(){
	#insert file name and size into the initialised database
	sqlite3 $db_location "insert into filesAndSizes (filename,filesize) values ('${1}','${2}');"
}

function selectAllDBRecords(){
	#print out all the records from the file and size db table in a column format with headers.  also ordered by the file size column
	printf '.mode column\n.headers on\nselect filename as "Filenames", filesize as "Size KB" from filesAndSizes order by filesize;' | sqlite3 $db_location
}



#--------- Check Args ---------

if [[ $# -eq 0 ]]; then
	#if there are no arguments echo the error and exit with an exit code of 1
	errorCode=1
	echo "Error(${errorCode}): No argument provided"
	echo "Syntax:"
	echo "./10443748_week3 [filepath]"
	exit $errorCode
elif [[ $# -ne 1 ]] || [[ ! -d $1 ]]; then
	#if there are more than 1 argument or the argument isnt a directory then exit with error code 2 and echo the error text
	errorCode=2
	echo "Error(${errorCode}): Incorrect number of arguments or the location is not valid"
	echo "Syntax:"
	echo "./10443748_week3 [filepath]"
	exit $errorCode
else #Success - perform main processing
	fileLocation=$1
	#create the db file and table if it doesnt exist
	initDB
	#loop over files in the location
	for f in $fileLocation/*
	do
		#if 'f' is a file
		if [ -f "${f}" ];
		then
			#get the file size in 1000 byte blocks and store the number in variable filesize
			filesize=`du --block-size=KB "${f}" | awk '{print $1}' | sed 's/kB//g'`
			#store the base part of the filename into variable filename
			filename=`basename "${f}"`
			#call the insert db function with the filename and filesize variable
			insertDBRecord "${filename}" "${filesize}"
		fi
	done
	#display all the files and sizes recorded in the db
	selectAllDBRecords
	exit 0
fi
