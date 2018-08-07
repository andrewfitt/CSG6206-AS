#!/bin/bash

target=../Workshop1/myfolder/misc

s1=256x256
s2=512x512
s3=1024x1024

s1_count=0
s2_count=0
s3_count=0

declare -a s1_list
s2_list[0]=""
s3_list[0]=""

for file in $target/*
do
	image_size=`identify $file | awk '{ print $3 }'`
	#echo $image_size
	if [[ $image_size == $s1 ]]
	then
		s1_list[s1_count]=$file
		let s1_count=s1_count+1
		
	elif [[ $image_size == $s2  ]]
	then
		s2_count=$[s2_count+1]
		
	else
		let s3_count++
	fi
done

echo $s1 = $s1_count
echo $s2 = $s2_count
echo $s3 = $s3_count

echo $s1_list
echo ${s1_list[*]}
