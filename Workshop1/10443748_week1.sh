#!/bin/bash

# Workshop 1
# Download misc.zip from http://sipi.usc.edu/database/database.php?volume=misc
# Extract it to a folder
# Delete the downloaded file
# Output the progress in each step
#

$error = ""

echo "Begining process"


echo "Download the file"
wget http://sipi.usc.edu/database/misc.zip
echo "Download complete"
echo "Making target folder"
mkdir myfolder
echo "Folder created"
echo "Exctracting file contents"
unzip misc.zip -d myfolder
echo "completed unzip"
echo "deleting the original file"
rm misc.zip
echo "file deleted"
echo "Done"

