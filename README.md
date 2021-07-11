# Legislation and Regulation Search - LARS #

This script is designed to search through legislative/regulatory XML files from the [Department of Justice Laws website](https://justice.gc.ca) for a given set of search terms and pass back a CSV formatted output like in the form:
```Title of Legislation```, ```Legislative Provision Reference```, ```Search Term Found```

## Example ##

To search the [Income Tax Regulations](https://laws-lois.justice.gc.ca/eng/regulations/C.R.C.,_c._945/index.html) for the term "remuneration" you download the [Income Tax Regulations XML](https://laws-lois.justice.gc.ca/eng/XML/C.R.C.,_c._945.xml) and set

```$xmlFileList = Get-ChildItem "/path/to/file.xml"``` and set the search term:
```$searchterm = "remuneration"```

When you run, the script will the following information for every occurence of the search term within the XML file or files you are searching.

The format of the output is comma separated values like"
```Title of Legislation```, ```Legislative Provision Reference```, ```Search Term Found```

You can also search for multiple search terms and multiple files.  For example, to search all downloaded XML files for "permit" and "licence" you download the XML files for every act or regulation you want to search and then change

```$xmlFileList = Get-ChildItem "/path/to/*.xml"``` and set the search term:
```$searchterm = "permit", "licence```

## Authors ##

- [Gordon D. Bonnar](https://www.github.com/gordbot)
- [Cody Bonnar](https://github.com/cbonnar)