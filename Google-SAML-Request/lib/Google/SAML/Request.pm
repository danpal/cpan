#  Copyright (c) 2008 Manni Heumann. All rights reserved.
#
#  This program is free software; you can redistribute it and/or
#  modify it under the same terms as Perl itself.

package Google::SAML::Request;

=head1 NAME

Google::SAML::Request -

=head1 VERSION

You are currently reading the documentation for version 0.01

=head1 DESCRIPTION


=head1 SYNOPSIS

 use Google::SAMLResponse;

=head1 PREREQUISITES

You will need the following modules installed:

=over

=item * MIME::Base64

=item * Compress::Zlib

=back

=head1 METHODS

=cut

use strict;
use warnings;

use MIME::Base64;
use Compress::Zlib;
use Carp;


our $VERSION = '0.01';


sub new_from_cgi {
    my $class = shift;
    my $param = shift;

    my $self = {};

    bless $self, $class;

    my $cgi_param = ( exists $param->{cgi_parameter} ) ?  $param->{cgi_parameter} : 'SAMLRequest';

    require CGI;
    my $encoded = CGI->new()->param( $cgi_param );
    if ( $self->_decode_saml_msg( $encoded ) ) {
        return $self;
    }
    else {
        return;
    }
}


sub _decode_saml_msg {
    my $self = shift;
	my $msg  = $self->{request};
    $self->{inflated_SAMLRequest} = undef;

	my $decoded = decode_base64( $msg );

	my ( $i, $status ) = inflateInit( -WindowBits => -&MAX_WBITS() );

	if ( $status == Z_OK ) {
		my $inflated;
		($inflated, $status) = $i->inflate( $decoded );

		if ( $status == Z_OK || $status == Z_STREAM_END ) {
		    $inflated =~ m/AssertionConsumerServiceURL="([^"]+)"/;
		    $self->{service_url} = $1;
		    $self->{inflated_SAMLRequest} = $inflated;
		    return 1;
		}
		else {
			warn "Could not inflate";
		}
	}
	else {
		warn "no inflater";
	}

	return;
}


=head1 TODO

=over

=item * Add support for DSA keys

=back

=head1 AUTHOR

Manni Heumann


=head1 LICENSE

Copyright (c) 2008 Manni Heumann. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut


1;
