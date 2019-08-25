#!/usr/bin/php
<?php

/*
Portfolio 2
Workshop 7
Process a text file for statistics and output the results in a html file

Author: Andrew Fitt
Date: 5/9/2018
CSG6206.2018.2

Syntax
  The script takes a file input of text and outputs an html file with statistics of the input file
  10443748_week7.php -i [file_in] -o [file_out]


Statistics | Count
Number of vowels | [num]
Number of consonants | [num]
Number of sentences | [num]
Number of words | [num]

Two colour heat map of the [A-Z] characters present in the text file.
Yellow to Green
rgb(255,255,30) to rgb(0,160,150)
*/

error_reporting(E_ERROR);

define("rgbMin",serialize (array(0,160,150)));
define("rgbMax",serialize (array(255,255,30)));


$htmlString = "<html><head>";
$htmlStyle = <<<HTMLSTYLE
<style>
    body {padding: 20px;font-family: Helvetica;}
    table {border-collapse: collapse;font-family: arial, sans-serif;}
    table.statistics {width:300px}
    tr.statistics {background-color: orange;color: white;}
    ul.heatmap {display: grid;grid-template-columns: repeat(6, 50px);grid-gap: 2px;vertical-align: middle;}
    li.heatmap {grid-template-rows:repeat(5, 50px);background-color: grey;border-radius: 3px;padding: 20px;vertical-align: middle;font-size: 14px;list-style-type:none}
    li.legend {height: 10px;list-style-type:none}
    #legend {width: 150px;float: left;}
    td {border: 1px solid #dddddd;}
    #wrapper {margin: 0 auto;width: 1000px;}
    #content {float: left;width: 400px;padding-right: 50px;}
    ul.legend {display: grid;grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));}
</style>
HTMLSTYLE;

$fileIn = "";
$fileOut = "";
$fileContents = "";
$charCountArray = array();


foreach (range('A', 'Z') as $c){
    $charCountArray[$c] = 0;
}


/*
 * ***********Functions***********
 */


function incorrectSyntax() {
  die("Error, incorrect syntax\n\n10443748_week7.php -i [file_in] -o [file_out]\n");
}


function getArgs() {
    $cli_options = "i:"; // Input and filename
    $cli_options .= "o:"; // Output filename

    $options = getopt($cli_options);

    if ($GLOBALS['argc']!=5 || count($options) != 2) {
      incorrectSyntax();
    }
    if (is_null($options["o"]) || is_null($options["i"])) {
      incorrectSyntax();
    }
    else {
        $GLOBALS['fileIn'] = $options["i"];
        $GLOBALS['fileOut'] = $options["o"];
    }
}

function fileRead($fileIn) {
    try {
        $tempFile = "";
        if (file_exists($fileIn)) {
            $tempFile = file_get_contents($fileIn, false) or die('Unable to read the file: ' . $fileIn);
        }
        else{
          die('File '.$fileIn.' does not exist.');
        }
        return $tempFile;
    }
    catch(Exception $e) {
        throw $e;
    }
}

function fileWrite($fileOut,$content) {
    try {
      $file = fopen($fileOut, "w");
      if($file==false){
        die("Unable to create or write to the file ".$fileOut);
      }
      else {
        $byteCount = fwrite($file, $content);
        echo "Done\n".$byteCount." bytes written to file ".$fileOut;
        fclose($file);
      }
    }
    catch(Exception $e) {

    }
}



function countWords($fileContents) {
    //Count all Words, Excluding WebURLs which we count the domain levels separately, Include plurals.
    //   Hyphenated words are counted as separate words otherwise include \-.
    //   Some "non-words" are counted as a word such as heading numbers in roman numerals are also counted.
    $count = preg_match_all("/(?:[[:alpha:]]+(?i)(('ll)|('ve)|('re)))|(?:[[:alpha:]]+\'(?i)[mst])|(?:[[:alpha:]]+[sS]')|(?:'[[:alpha:]]{2,})|(?:[[:alpha:]]){2,}|I|a|A/m",$fileContents);
    return $count;
}

function countSentences($fileContents) {
    /*
     * With the example text "Alice in wonderland" this was problematic because of the artificial word wrap
     *  and the arbitrary characters amongst the text.
     * My regex was initially any number of characters except '.' or '!' or '?' then finishing with the same
     *  characters and a space [^.!?]*[.!?]
     *
     * The following performs a more complete search that ignores characters such as " within a sentence.
     * [^.!?\s][^.!?]*(?:[.!?](?!['"]?\s|$)[^.!?]*)*[.!?]?['"]?(?=\s|$)
     * (Roberson, 2011)
     */

    $count = preg_match_all('/[^.!?\s][^.!?]*(?:[.!?](?![\'"]?\s|$)[^.!?]*)*[.!?]?[\'"]?(?=\s|$)/m',$fileContents);
    return $count;
}

function countVowels($fileContents) {
    // Refuse to count y as a vowel! ;-)
    $count = preg_match_all('/[aeiou]/im',$fileContents);
    return $count;
}

function countConsonants($fileContents) {
    //Match all a-z case insensitive except (negative lookahead ?!) the vowels
    $count = preg_match_all('/(?![aeiou])[a-z]/im',$fileContents);
    return $count;
}


function countLetters($fileContents) {
    $count = preg_match_all('/[a-z]/im',$fileContents,$matchedChars);
    $charArray = array();
    foreach ($matchedChars[0] as $char){
        $c = strtoupper($char);
        isset($charArray[$c]) ? $charArray[$c]++ : $charArray[$c]=1;
    }
    ksort($charArray);
    return $charArray;
}



function alphaHeatMap($charArrayIn){


    /*
 * For each primary colour
 * Round To Zero Decimal places (MinInt + ((MaxInt-MinInt) * (MinCharCount/MaxCharCount))
 */

    $valArray = array();
    $rgbMin = unserialize(rgbMin);
    $rgbMax = unserialize(rgbMax);
    $maxChars = max($charArrayIn);


    $strOut ="<div id='wrapper'><div id='content'><ul class='heatmap'>";
    $i=0;
    foreach ($charArrayIn as $char => $value) {
        $redVal = intval(round($rgbMin[0]+(($rgbMax[0]-$rgbMin[0])*($value/$maxChars)),0));
        $greenVal = intval(round($rgbMin[1]+(($rgbMax[1]-$rgbMin[1])*($value/$maxChars)),0));
        $blueVal = intval(round($rgbMin[2]+(($rgbMax[2]-$rgbMin[2])*($value/$maxChars)),0));
        $valArray += array($value => array($char,"rgb(".$redVal.",".$greenVal.",".$blueVal.")"));
        $strOut.="<li class='heatmap' style='"."background-color: rgb(".$redVal.",".$greenVal.",".$blueVal.")'>".$char."</li>";
    }
    krsort($valArray);
    $strOut.="</ul></div>";
    $strOut.="<div id='legend'>";
    $strOut.="<ul class='legend'><li class='legend' style='height: 40px;width: 180px'>Highest to Lowest Character Occurrence</li>";
    foreach ($valArray as $key => $rgb) {
      $strOut.="<li class='legend' style='background-color: ".$rgb[1]."'></li>";
    }
    $strOut.="</ul></div></div>";
    return $strOut;
}

/*
 * ************** Main code calls ******************
 */


getArgs();
try {

  //   Statistics Table Content

    $fileContents = fileRead($fileIn);
    $charCountArray = countLetters($fileContents);
    $wordCount = countWords($fileContents);
    $sentencesCount = countSentences($fileContents);
    $vowelCount = countVowels($fileContents);
    $consonantsCount = countConsonants($fileContents);


    //Build the html string output

    $htmlString.=$htmlStyle;
    $htmlString.="</head><body>";

    //Add count table
    $htmlString.= <<<table1
    <table class="statistics">
        <tr class="statistics">
            <th>Statistics</th>
            <th>Count</th>
        </tr>
        <tr>
            <td>Number of vowels</td>
            <td>$vowelCount</td>
        </tr>
        <tr>
            <td>Number of consonants</td>
            <td>$consonantsCount</td>
        </tr>
        <tr>
            <td>Number of sentences</td>
            <td>$sentencesCount</td>
        </tr>
        <tr>
            <td>Number of words</td>
            <td>$wordCount</td>
        </tr>
    </table>
table1;


    $htmlString.="<br><br>";

  //   Include the Heat map html

    $htmlString.=alphaHeatMap($charCountArray);

  //   close the html string
    $htmlString.="</body></html>";

  //write the html string to file
    fileWrite($fileOut,$htmlString);

}

//catch exceptions
catch(Exception $e) {
    echo 'Error: ' .$e->getMessage();
}



/*
 * References
 * Roberson, J. M. (2011). Regular expression match a sentence. Retrieved from https://stackoverflow.com/questions/5553410/regular-expression-match-a-sentence
 *
 */
?>



