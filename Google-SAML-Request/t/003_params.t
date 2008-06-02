# -*- perl -*-

use strict;
use warnings;

use Test::More tests => 11;
use Test::Exception;

BEGIN {
    use_ok( 'Google::SAMLResponse' );
}

my $request = 'fZJNb9swDIbvBfofBN1tKxkGdELsIEtRNEA/jMbZYTdFZmK1+poox+u/r+I0WHdoj6JIvs9Lcjb/azQ5QEDlbEknOaMErHStsvuSbpqb7IrOq8uLGQqjPV/0sbNP8KcHjCRVWuTjR0n7YLkTqJBbYQB5lHy9uL/j05xxH1x00mlKVtclNS9WONg+dy14A88vUlnYee3brbd62+07JTvnraPk1xlresRaIfawshiFjSnE2FXGvmdT1rAfnDH+jf2mpH5X+qnsycFXWNtTEvLbpqmz+nHdjA0OqoXwkLJLunduryGXzlCyQIQQE87SWewNhDWEg5KweboraRejR14UwzDk/4oKUQwmprI039Nb4tFHLRDVIfXfCY1Aq3G4fPQXPkz1a3px5qHV54qz4kPr6n2JR2+r69ppJV/JQms3LAOImHhi6IGSGxeMiJ+rT/LJGFFtthtTeW/Rg1Q7BS0lRXVS/f9a0g29AQ==';
my $saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );
isa_ok( $saml, 'Google::SAMLResponse' );

dies_ok { $saml = Google::SAMLResponse->new() } 'new should die when called without any parameters';
dies_ok { $saml = Google::SAMLResponse->new( { login => 'someone', request => $request } ) } 'new should die when called without the key parameter';
dies_ok { $saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', request => $request } ) } 'new should die when called without the login parameter';
dies_ok { $saml = Google::SAMLResponse->new( { login => 'someone', key => 't/rsa.private.key' } ) } 'new should die when called without the request parameter';

$saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );
is( $saml->{ttl}, 2*60, 'Default for ttl is 2 minutes' );
is( $saml->{canonicalizer}, 'XML::CanonicalizeXML', 'Default for canonicalizer is XML::CanonicalizeXML' );
is( $saml->{request}, $request, 'Request is stored in object' );
is( $saml->{login}, 'someone', 'Login is stored in object' );
is( $saml->{key}, 't/rsa.private.key', 'Key is stored in object' );

