#!/usr/bin/perl

use strict;
use warnings;

use Carp;
use Data::Dumper;
use Text::ASCIITable;

use Text::CSV;
use Getopt::Long;

my %options = (
    'file' => undef,
);

GetOptions( \%options, 'file=s', );

if ( !$options{'file'} ) {
    print "Mandatory param file: --file file.csv \n";
    exit;
}

my $input_filehandler;

if ( !open( $input_filehandler, '<:utf8', $options{'file'} ) ) {
    print "Cannot open file\n";
    exit;
}

my $csv          = Text::CSV->new();
my $first_row    = $csv->getline( $input_filehandler );
my @file_columns = @{ $first_row };

my $t = Text::ASCIITable->new( { headingText => $options{'file'} } );
$t->setCols( @file_columns );

$csv->column_names( @file_columns );

my $count = 4;

for my $it ( @file_columns ) {
    $count += length( $it ) + 2;
}

while ( my $row = $csv->getline( $input_filehandler ) ) {
    $t->addRow( $row );
}

print $t;
