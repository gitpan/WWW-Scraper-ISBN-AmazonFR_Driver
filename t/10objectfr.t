#!/usr/bin/perl -w
use strict;


use Test::More tests => 14;

###########################################################

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

$scraper->drivers("AmazonFR");
my $isbn = "0596000278";
my $record = $scraper->search($isbn);

 SKIP: {

     skip($record->error,6)  if($record->error =~ m/^Error/);     
     
     is($record->found,1,"found?");
     is($record->found_in,'AmazonFR',"checking driver name");
     
     my $book = $record->book;
     is($book->{isbn},'0596000278',"checking isbn");
     like($book->{title},qr{^Programming Perl},'title');
     is($book->{author},'Wall','author');
     is($book->{publisher},q{O'Reilly},'publisher');
 }

$isbn = "2841771407";
$record = $scraper->search($isbn);

 SKIP: {
     skip($record->error,7) if($record->error =~ /^Error/);
     
     is($record->found(),1);
     is($record->found_in(),'AmazonFR');
     
     my $book = $record->book;
     is($book->{isbn},'2841771407');

     like($book->{title},qr{^Programmation en Perl},'title');
     is($book->{author},'Larry Wall','author');
     is($book->{publisher},q{O'Reilly},'publisher');
     is($book->{pubdate},'18 septembre 2001');
 }

###########################################################

