# -*- perl -*-

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
    use_ok( 'Google::SAMLResponse' );
}

if ( `xmlsec1` ) {
}

SKIP: {
    skip "HTML::Lint not installed", 3 unless `xmlsec1`;

    my $request = 'fZJNb9swDIbvBfofBN1tKxkGdELsIEtRNEA/jMbZYTdFZmK1+poox+u/r+I0WHdoj6JIvs9Lcjb/azQ5QEDlbEknOaMErHStsvuSbpqb7IrOq8uLGQqjPV/0sbNP8KcHjCRVWuTjR0n7YLkTqJBbYQB5lHy9uL/j05xxH1x00mlKVtclNS9WONg+dy14A88vUlnYee3brbd62+07JTvnraPk1xlresRaIfawshiFjSnE2FXGvmdT1rAfnDH+jf2mpH5X+qnsycFXWNtTEvLbpqmz+nHdjA0OqoXwkLJLunduryGXzlCyQIQQE87SWewNhDWEg5KweboraRejR14UwzDk/4oKUQwmprI039Nb4tFHLRDVIfXfCY1Aq3G4fPQXPkz1a3px5qHV54qz4kPr6n2JR2+r69ppJV/JQms3LAOImHhi6IGSGxeMiJ+rT/LJGFFtthtTeW/Rg1Q7BS0lRXVS/f9a0g29AQ==';
    my $saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );
    my $xml = $saml->get_response_xml();
    ok( $xml );
    if ( open my $XML, '>', 'tmp.xml' ) {
        print $XML $xml;
        close $XML;
    }
    else {
        ok( 0, "Could not open temporary file tmp.xml: $!" );
    }
    my $verify_response = `xmlsec1 --verify tmp.xml 2>&1`;
    ok( $verify_response =~ m/^OK/, "Response is OK for xmlsec1" );
}
