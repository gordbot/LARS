<#
.DESCRIPTION.
This script is designed to search through legislative/regulatory XML files from the Justice.gc.ca website for a given 
set of search terms, and pass back a CSV formatted output as below:
Title of Legislation, Legislative Reference, Search Term Found

.AUTHOR.
Gordon D. Bonnar <Gordon.Bonnar@cra-arc-gc-ca)

.LICENCE.
Copyright (c) Microsoft Corporation.

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>



# Which XML files do you want to search?
$xmlFileList = Get-ChildItem "XML\*.xml"

# $searchterms is a comma separated list (array) of the terms to search for.
# $searchterms = "registered mail", "facsimile"
$searchterms = "registered mail", "facsimile"


# Get-LegisRef returns the legislative reference for the XML object passed to it. May require some tuning as the
# Justice.gc.ca XML standard varies.
function Get-LegisRef {
    param (
        $legisobject
    )
    if($legisobject.name -eq "Section" -or $legisobject.name -eq "Order") {
        #Some section labels have footnote references so you need innertext in those scenarios.
        if(($legisobject.label.GetType()).Name -eq "XmlElement") {
            return $legisobject.label.InnerText
        } else {
            return $legisobject.label
        }
    } elseif($legisobject.name -eq "Schedule") {
        if(($legisobject.ScheduleFormHeading.label.GetType()).Name -eq "XmlElement") {
            # Some acts/legislation have bilingual language labels which requires parsing the below parsing.
            return ($legisobject.ScheduleFormHeading.label.Language | ? { $_."lang" -eq "en" })."#text"
        } else {
            return $legisobject.ScheduleFormHeading.label
        }
    } elseif($legisobject.name -eq "Definition") {
        # Text nodes inside Definition nodes contain child nodes themselves, requiring the parsing below.
        (Get-LegisRef $legisobject.ParentNode) + $legisobject.label + " - Definition of: " + $legisobject.Text.DefinedTermEn
    } else {
        # This concatenates the legislative reference text as the recursive function works its way up the chain.
        (Get-LegisRef $legisobject.ParentNode) + $legisobject.label
    }
}


# Function searches all Text nodes in the passed XML file for the passed search term.
function SearchLeg {
    param (
        $xmlElm,
        $searchterm
    )
    # Looks for each node containing a text node, passes that to a where-object that checks 
    # if the text or innertext (in the case of text nodes containing child nodes) contains the search term
    # and then passes the node to Get-LegisRef. 
    $xmlElm.SelectNodes('//Text').ParentNode | ? { if($_.Text.GetType().Name -eq "XmlElement") { $_.InnerText -match $searchterm } else { $_.Text -match $searchterm } } | % { Get-LegisRef $_ }
}


#Loops through each XML file for each piece of legislation/regulation.
foreach($xmlFile in $xmlFileList) {
    [xml]$xml = Get-Content $xmlFile # Opening the XML file

    # Determining the title of the legislation/regulation.
    if($xml.SelectNodes('//ShortTitle')."#text") {
        $title = $xml.SelectNodes('//ShortTitle')."#text"
    } elseif($xml.SelectNodes('//LongTitle')."#text") {
        $title = $xml.SelectNodes('//LongTitle')."#text"
    } else {
        $title = $xmlFile
    }

    #$title # Used for debugging
    
    #Loops through each term in $searchterms.
    foreach ($term in $searchterms) {
        #"----- " + $term + " -----" # Used for debugging
        # Passes the output from SearchLeg into a foreach loop that prints out CSV formatted data for the title of the legislation, the section, and the term found.
        SearchLeg -searchterm $term -xmlElm $xml | % { "`"$title`"" + "," + "`"$_`"" +","+ "`"$term`"" } | sort -unique
    }
}
