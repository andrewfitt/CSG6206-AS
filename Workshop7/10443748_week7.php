#!/usr/bin/php
<?php

// Syntax
// The script takes a file input of text and outputs an html file with statistics of the input file
// 10443748_week7.php [file_in] [file_out]

/*
Statistics | Count
Number of vowels | [num]
Number of consonants | [num]
Number of sentences | [num]
Number of words | [num]


Two Colour Heatmap
Yellow to Green
rgb(255,255,0) to rgb(0,160,0)
Two values to Calc  using this:
(Upper Value - Lower Value) / [how many steps left]
count the number of steps by the max num uniq values in the [A-Z] sums
*/
$cli_options = "";
$cli_options = "i:"; // Input filename
$cli_options .= "o:"; // Output filename

$options = getopt($cli_options);
var_dump($options);


if ($options["i"] == "" || $options["o"] == "") {
    echo "Error, incorrect syntax\n";
    echo "Syntax\n";
    echo "10443748_week7.php -i [file_in] -o [file_out]\n";
    exit(1);
}
else {
    $fileIn = $options["i"];
    $fileOut = $options["o"];
}




function fileRead($fileName){
    if (file_exists($fileName))
    {
        $fileContents = file_get_contents($fileName,false);
    }
}

function countWords($fileContents){

}

function countSentences($fileContents){

}

function countVowelsAndConsonants($fileContents){

}

?>
