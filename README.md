# Legislation and Regulation Search - LARS

This script is designed to search through legislative/regulatory XML files from the Justice.gc.ca website for a given 
set of search terms, and pass back a CSV formatted output like: Title of Legislation, Legislative Provision Reference, Search Term Found

## Usage
Change the path in $xmlFileList to a single file or a file glob.

Change the $searchterms array to include a comma separated list of search terms as quoted strings.

The script will search each XML file in the list of XML files and check to see if any of the search terms can 
be found in the legislation or regulations.  If a match is found, the function recursively works through the parent nodes yielding a full legislative reference to the lowest level occurence of the search term.

The script can handle search terms in definition subsections by providing a reference to the section with the definitions and then an optional refernce to the exact use of the term in a pargraphed definition.
