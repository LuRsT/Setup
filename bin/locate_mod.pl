#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use Data::Dumper;

my $LOCATE= q{/usr/bin/locate};

scalar( @ARGV) || croak "Missing madatory param";

for my $mod ( @ARGV ) {
    #print "\n$mod\n";
    my $path = $mod;
    $path =~ s/::/\//g;
    $path =~ s/://g;
    $path =~ s/\./\//g;
    my $res = `$LOCATE $path`;
    chomp( $res );
    $res =~ s/\r/\t\n/g;

    for my $path ( split("\n", $res ) ) {
        print $path . ":1:1\n";
    }
}
