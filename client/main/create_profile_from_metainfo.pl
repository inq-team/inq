#!/usr/bin/perl

use strict;
use warnings;

use XML::Writer;

my $i;
my $x;
my $exist;
my @files;
my @to_parse;

die "Usage: create_profile_from_metainfo.pl directory_with_tests\n" if $#ARGV != 0;

# Read directory contents
opendir DIR, $ARGV[0];
@files = readdir DIR;
closedir DIR;
map { $_ = $ARGV[0] . "/" . $_ } @files;

# Begin XML
$x = new XML::Writer(DATA_MODE => 1, DATA_INDENT => 1);
$x->startTag("tests");

# We need only files
for($i = 0; $i < $#files; $i++){
	push @to_parse, $files[$i]
	unless $files[$i] =~ /\.$/ or -d $files[$i];
};

foreach(@to_parse){
	my $file = $_;
	my $type = +(split '/', $file)[-1];

	# Check for variables existence in metainformation
	$exist = 0;
	open FD, "< $_";
	while(<FD>){ /^# VAR=/ && $exist++; };
	close FD;
	$exist || next;

	# Insert them into XML
	$x->startTag("test", "id" => $type, "type" => $type);
	open FD, "< $file";
	while(<FD>){
		/^# VAR=(.*):\w+:(.*):/ || next;
		$x->dataElement("var", "$2", "name" => $1);
	};
	close FD;
	$x->endTag("test");
};
$x->endTag("tests");
