# -*- perl -*-

use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;

BEGIN {
    use_ok( 'Google::SAMLResponse' );
}

my $modulus = '1b+m37u3Xyawh2ArV8txLei251p03CXbkVuWaJu9C8eHy1pu87bcthi+T5WdlCPKD7KGtkKn9vqi4BJBZcG/Y10e8KWVlXDLg9gibN5hb0Agae3i1cCJTqqnQ0Ka8w1XABtbxTimS1B0aO1zYW6d+UYl0xIeAOPsGMfWeu1NgLChZQton1/NrJsKwzMaQy1VI8m4gUleit9Z8mbz9bNMshdgYEZ9oC4bHn/SnA4FvQl1fjWyTpzL/aWF/bEzS6Qd8IBk7yhcWRJAGdXTWtwiX4mXb4h/2sdrSNvyOsd/shCfOSMsf0TX+OdlbH079AsxOwoUjlzjuKdCiFPdU6yAJw==';
my $exponent = 'Iw==';
my $request = 'fZJNb9swDIbvBfofBN1tKxkGdELsIEtRNEA/jMbZYTdFZmK1+poox+u/r+I0WHdoj6JIvs9Lcjb/azQ5QEDlbEknOaMErHStsvuSbpqb7IrOq8uLGQqjPV/0sbNP8KcHjCRVWuTjR0n7YLkTqJBbYQB5lHy9uL/j05xxH1x00mlKVtclNS9WONg+dy14A88vUlnYee3brbd62+07JTvnraPk1xlresRaIfawshiFjSnE2FXGvmdT1rAfnDH+jf2mpH5X+qnsycFXWNtTEvLbpqmz+nHdjA0OqoXwkLJLunduryGXzlCyQIQQE87SWewNhDWEg5KweboraRejR14UwzDk/4oKUQwmprI039Nb4tFHLRDVIfXfCY1Aq3G4fPQXPkz1a3px5qHV54qz4kPr6n2JR2+r69ppJV/JQms3LAOImHhi6IGSGxeMiJ+rT/LJGFFtthtTeW/Rg1Q7BS0lRXVS/f9a0g29AQ==';
my $saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );
isa_ok( $saml, 'Google::SAMLResponse' );

$saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );

isa_ok( $saml->{ rsa_key }, 'Crypt::OpenSSL::RSA', 'Key object is valid' );
is( $saml->{modulus}, $modulus, 'Modulus is correct' );
is( $saml->{exponent}, $exponent, 'Exponent is correct' );

dies_ok { $saml = Google::SAMLResponse->new( { key => 'foobar', request => $request, login => 'someguy' } ) } 'new shoud die when it cannot find the private key';
dies_ok { $saml = Google::SAMLResponse->new( { key => 'README', request => $request, login => 'someguy' } ) } 'new shoud die when the private key is invalid';