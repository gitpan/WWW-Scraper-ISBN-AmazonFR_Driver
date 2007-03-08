#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WWW::Scraper::ISBN::AmazonFR_Driver' );
}

diag( "Testing WWW::Scraper::ISBN::AmazonFR_Driver $WWW::Scraper::ISBN::AmazonFR_Driver::VERSION, Perl $], $^X" );
