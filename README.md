# My Setup

My dotfiles and ~/bin

### Requirements

* tidy
* rsync

#### Perl libs

* Text::ASCIITable
* Getopt::Long
* Text::CSV

## ~/bin

### soaper

bash script

My CLI soap client, needs some work but works for my use, receives two parameters, a file and a WSDL url

    soaper test.xml http://www.w3schools.com/webservices/tempconvert.asmx?op=FahrenheitToCelsius

Note: soaper dislikes \n inside tags

### view\_csv

Perl script

Pretty viewer for CSVs

    view_csv test.csv

### locate\_mod.pl

Perl script

Useful to locate modules by mod name.

    locate_mod.pl Data::Dumper

### barchart

Perl script

Displays a "barchart" for a text with duplicated string in it.

    barchart sample_data.txt
      00000000| Miniac
             0| Bossy
    0000000000| EPICAC
            00| The Prime Radiant
          0000| Multivac
            00| MARAX
      00000000| Mark V
         00000| Mima

### cleaner

Deletes trailing whitespaces from files.

Example use:

    # Removes trailing whitespace from python files
    # Also removes extra whitelines if there are more
    # than 3 whitelines
    find . -iname "*.py" | xargs -l cleaner

    # Is is known to corrupt git repos, so, NEVER do this:
    # find | xargs -l cleaner
