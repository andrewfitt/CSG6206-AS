
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
declare -A fileAndTypeList
declare -A typeList

Grayscale="Gray"
Colour="sRGB"

maxEntriesForTypes=0


function grayOrColour() {
	case $1 in
		$Grayscale) echo Grayscale ;;
		$Colour) echo Colour ;;
	esac
}


function readFileList() {
	# @description Read files from global path into global variable array
	# @TODO Will improve this to take a parameter and return an object if possible
	for file in ${imagesPath}
	do
		IFS='/' read -r -a filevals <<< `identify -format "%t/%[colorspace]" ${file}`
		imagetype=`grayOrColour ${filevals[1]}`
		filename=${filevals[0]}
		fileAndTypeList[${imagetype}]="${fileAndTypeList[${imagetype}]}/${filename}"
		typeList[${imagetype}]=$[typeList[${imagetype}]+1]
	done

	return
}

# Print our the variables
function printVars (){
	echo "-=-=-=-==-=- Variables --=-=-=-=-=-=-=-=-"
	for i in _ {a..z} {A..Z}; do
	   for var in `eval echo "\\${!$i@}"`; do
	      echo $var | grep type
	   done
	done
	return
}




function listPrintout(){
	for i in ${typeList[@]}
	do
		if [ "$i" -gt "$maxEntriesForTypes" ];then
			maxEntriesForTypes=$i
		fi
	done
}



# @desciption Build the dynamic lists for each type

for j in "${!typeList[@]}"
do
	imagetype=`grayOrColour ${j}`
	declare -g typelist_${imagetype}
	temp=typelist_${imagetype}[@]
	printf "%-15s" "$j"
	IFS='/' read -r -a typelist_${imagetype} <<< `echo "${fileAndTypeList[${imagetype}]}"`
done



for i in `seq 0 $[maxEntriesForTypes-1]`
do
	printf "%-15s%-15s\n" "${typelist_Color[$i]}" "${typelist_Grayscale[$i]}"
#	for j in "${!typeList[@]}"
#	do
#		declare -a templist=typelist_$j[@]
#		printf "[%-15s]" "${!templist[$i]}"
#	done
#	printf "\n"
done








readFileList
listPrintout

#printVars



