package WWW::Scraper::ISBN::AmazonFR_Driver;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.01';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::AmazonFR_Driver - Search driver for the (FR) Amazon online
catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the (FR) Amazon online catalog.
This module is a mere paste and translation of
L<WWW::Scraper::ISBN::AmazonUS_Driver>. The main (only?) difference is
in the parsing of the result. Here it is done with simple regexp, whereas in 
L<AmazonUS_Driver|WWW::Scraper::ISBN::AmazonUS_Driver> it was done using 
L<Template::Extract>. 

=cut

#--------------------------------------------------------------------------

###########################################################################
#Inheritence		                                                      #
###########################################################################

use base qw(WWW::Scraper::ISBN::Driver);

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Mechanize;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	AMAZON	=> 'http://www.amazon.fr/';
use constant	SEARCH	=> 'http://www.amazon.fr/';

#--------------------------------------------------------------------------

###########################################################################
#Interface Functions                                                      #
###########################################################################

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Amazon
(FR) server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn
  author
  title
  book_link
  thumb_link
  image_link
  pubdate
  publisher

The book_link, thumb_link and image_link refer back to the Amazon (FR) website. 

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mechanize = WWW::Mechanize->new();

	$mechanize->get( SEARCH );


	return	unless($mechanize->success());

	my ($index,$input) = (0,0);


	# The search form
	$mechanize->form_name('site-search');

	my $keyword;
	# This is to search for books 
        # (<select name="url"><option name="url" value="">... 
	$keyword ='search-alias=stripbooks';


	$mechanize->set_fields( 'field-keywords' => $isbn, 'url' => $keyword );

	$mechanize->submit();



	return	unless($mechanize->success());


        my $content=$mechanize->content();
	my ($con,$thumb, $image, $pub);

 	if(
	   $content =~ s{
	       .*
	   <meta \s  name="description"  \s content=" ( [^"]* ) "     .*
           <div  \s class="buying">                                   .*
           <script \s language=                                       .*
           function \s registerImage 
                         }{}msx
           )
           {$con=$1;}

	  if($content =~ s{

     <script>                                            .*
     registerImage\("original_image",
		   \s " ( [^"]* )  ",

                          }{}msx )
        {$thumb=$1;}

        if($content =~ s{
                \s "<a \s href="\+'"'\+" ( [^"]* ) "\+          .*
                <b \s class="h1">Description \s du \s produit</b><br\s /> 
}{}msx ){$image=$1};

         if($content =~s{
     <li><b>Editeur \s :</b> ( (?: [^\n](?!</li>) )* )
                }{}msx)
        {$pub=$1;}



        my $data = {};
        $data->{content} = $con;
        $data->{thumb_link} = $thumb;
        $data->{image_link} =$image;
        $data->{published}  =$pub;

	return $self->handler("Could not extract data from amazon.fr result page.")
		unless(defined $data);

	# trim top and tail
	foreach (keys %$data) { 
            next unless defined $data->{$_};
            $data->{$_} =~ s/^\s+//;
            $data->{$_} =~ s/\s+$//;
        }

	($data->{title},$data->{author}) = 
		($data->{content} =~ 
                  /Amazon.fr\s*:\s*
                  (.*)
                  :\s*Livres?.*
                  by\s+(.*)/x);


	($data->{publisher},$data->{pubdate}) = 
		($data->{published} =~ /\s*(.*?)(?:;.*?)?\s+\(([^)]*)/);

	my $bk = {
		'isbn'			=> $isbn,
		'author'		=> $data->{author},
		'title'			=> $data->{title},
		'image_link'	        => $data->{image_link},
		'thumb_link'	        => $data->{thumb_link},
		'publisher'		=> $data->{publisher},
		'pubdate'		=> $data->{pubdate},
		'book_link'		=> $mechanize->uri()
	};
	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=back

=head1 BUGS and LIMITATIONS


The following message can appear on STDERR (up to 2 times by request?) from
time to time
 
    Malformed UTF-8 character (unexpected end of string)
    in subroutine entry at
    (/some/path/to/the/module)/HTML/PullParser.pm line 83

This doesn't prevent C<search()> from completing its job and this
doesn't seems to be deterministic.

The calls C<< $mechanize->get( SEARCH ) >> (1 message) and
C<< $mechanize->submit() >> (2 messages) in C<search()> seams to be
responsible for this. So, I am tempted to blame amazon, but I didn't
checked.


=head1 REQUIRES

Requires the following modules be installed:

=over 4

=item L<WWW::Scraper::ISBN::Driver>

=item L<WWW::Mechanize>

=back

=head1 SEE ALSO

=over 4

=item L<WWW::Scraper::ISBN>

=item L<WWW::Scraper::ISBN::Record>

=item L<WWW::Scraper::ISBN::Driver>

=back

=head1 AUTHOR

Fabien GALAND, E<lt>galand@cpan.orgE<gt>

=head1 CREDIT

This is a mere paste and translation of
L<WWW::Scraper::ISBN::AmazonUS_Driver> written by Barbie,
E<lt>barbie@cpan.orgE<gt>.

=head1 COPYRIGHT

Copyright (C) 2007 Fabien Galand
All Rights Reserved.

This module is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=cut

