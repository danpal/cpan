# -*- perl -*-

use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;

BEGIN {
    use_ok( 'Google::SAMLResponse' );
}

my $request = 'fZJNb9swDIbvBfofBN1tKxkGdELsIEtRNEA/jMbZYTdFZmK1+poox+u/r+I0WHdoj6JIvs9Lcjb/azQ5QEDlbEknOaMErHStsvuSbpqb7IrOq8uLGQqjPV/0sbNP8KcHjCRVWuTjR0n7YLkTqJBbYQB5lHy9uL/j05xxH1x00mlKVtclNS9WONg+dy14A88vUlnYee3brbd62+07JTvnraPk1xlresRaIfawshiFjSnE2FXGvmdT1rAfnDH+jf2mpH5X+qnsycFXWNtTEvLbpqmz+nHdjA0OqoXwkLJLunduryGXzlCyQIQQE87SWewNhDWEg5KweboraRejR14UwzDk/4oKUQwmprI039Nb4tFHLRDVIfXfCY1Aq3G4fPQXPkz1a3px5qHV54qz4kPr6n2JR2+r69ppJV/JQms3LAOImHhi6IGSGxeMiJ+rT/LJGFFtthtTeW/Rg1Q7BS0lRXVS/f9a0g29AQ==';
my $saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );
isa_ok( $saml, 'Google::SAMLResponse' );

$saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );

ok( $saml->{service_url} eq 'https://www.google.com/a/wmtserver.com/acs', 'Decoded request contains login url' );
ok( $saml->{inflated_SAMLRequest} =~ m/^<\?xml /, 'Decoded request contains start of xml' );
ok( $saml->{inflated_SAMLRequest} =~ m{</samlp:AuthnRequest>\s+$}, 'Decoded request contains end of xml' );

