use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::Scraper::ISBN::AmazonFR_Driver',
    AUTHOR              => 'Fabien Galand <galand@cpan.org>',
    VERSION_FROM        => 'lib/WWW/Scraper/ISBN/AmazonFR_Driver.pm',
    ABSTRACT_FROM       => 'lib/WWW/Scraper/ISBN/AmazonFR_Driver.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'                  => 0.45,
	'WWW::Scraper::ISBN'          => 0.25,
	'WWW::Scraper::ISBN::Record'  => 0,
        'WWW::Scraper::ISBN::Driver'  => 0.18,
        'WWW::Mechanize'              => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Scraper-ISBN-AmazonFR_Driver-*' },
);
