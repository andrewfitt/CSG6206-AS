#!/bin/bash

#	Workshop 2 (Week 2 assessment)
#	Author: Andrew Fitt
# 	Date: 7 August 2018
#
#
#	Requirements
#	From the list of files provided, output a table of files in each colourspace eg Colour and Grayscale
#
#	Must have:
#		At least one function
#		String processing to ensure the correct table output
#		Correct column and row output and structure
#
#	Marking rubric includes:
#		Use of one inbuilt command (bash or sh?)
#		Use of a loop for counting
#		Use an Array to store


imagesPath="../Workshop1/myfolder/misc/*"
declare -A -g fileAndTypeList
declare -A -g typeList
declare -g imagetype=""


declare -g Grayscale="Gray"
declare -g Colour="sRGB"

maxEntriesForTypes=0


function grayOrColour() {
	case $1 in
		$Grayscale)
			echo "Grayscale"
			;;
		$Colour)
			echo "Colour"
			;;
		"Gray")
			echo "Grayscale"
			;;
		"sRGB")
			echo "Colour"
			;;
		"Colour")
			echo "Colour"
			;;
		"Grayscale")
			echo "Grayscale"
			;;
	esac
}



function readFileList() {
	# @description Read files from global path into global variable array
	for file in ${imagesPath}
	do
		IFS='/' read -r -a filevals <<< `identify -format "%t/%[colorspace]" ${file}`
		imagetype=`grayOrColour ${filevals[1]}`
		filename=${filevals[0]}
		fileAndTypeList[${imagetype}]+="/${filename}"
		typeList[${imagetype}]=$[typeList[${imagetype}]+1]
	done
}


# Print out the variables
function printVars (){
	echo "-=-=-=-==-=- Variables --=-=-=-=-=-=-=-=-"
	for i in _ {a..z} {A..Z}; do
	   for var in `eval echo "\\${!$i@}"`; do
	      echo $var | grep type
	   done
	done
}



function listCount(){
	# @description Count the entries in the lists of each type of colour space recorded
	for i in ${typeList[@]}
	do
		if [ "$i" -gt "$maxEntriesForTypes" ];then
			maxEntriesForTypes=$i
		fi
	done
}


function buildTypeLists(){
	# @description Create a new array for each type of colour space and assign filenames to the corresponding type
	for j in "${!typeList[@]}"
	do
		declare -g typelist_${j}
		IFS='/' read -r -a typelist_${j} <<< `eval echo ${fileAndTypeList[$j]}`
	done
}


function printTypesAndFiles(){
	# @description Output to standard out the arrays of each colour space with the files that correspond and format in columns
	for j in "${!typeList[@]}"
	do
	printf "%-15s" $j
	done

	for i in `seq 0 $[maxEntriesForTypes-1]`
	do
		for j in "${!typeList[@]}"
		do
			eval tmpval='${typelist_'${j}'['${i}']}'
			printf "%-15s" $tmpval
		done
		printf "\n"
	done
}


#-=-=-=-=-=-=-   Call functions   -=-=-=-=-=-=-=-==-

readFileList

listCount

buildTypeLists

printTypesAndFiles



#printVars

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
