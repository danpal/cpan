# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN {
    use_ok( 'Google::SAMLResponse' );
}

my $saml = Google::SAMLResponse->new(
    {
        key     => 't/rsa.private.key',
        request => 'fZJNb9swDIbvBfofBN1tKxkGdELsIEtRNEA/jMbZYTdFZmK1+poox+u/r+I0WHdoj6JIvs9Lcjb/azQ5QEDlbEknOaMErHStsvuSbpqb7IrOq8uLGQqjPV/0sbNP8KcHjCRVWuTjR0n7YLkTqJBbYQB5lHy9uL/j05xxH1x00mlKVtclNS9WONg+dy14A88vUlnYee3brbd62+07JTvnraPk1xlresRaIfawshiFjSnE2FXGvmdT1rAfnDH+jf2mpH5X+qnsycFXWNtTEvLbpqmz+nHdjA0OqoXwkLJLunduryGXzlCyQIQQE87SWewNhDWEg5KweboraRejR14UwzDk/4oKUQwmprI039Nb4tFHLRDVIfXfCY1Aq3G4fPQXPkz1a3px5qHV54qz4kPr6n2JR2+r69ppJV/JQms3LAOImHhi6IGSGxeMiJ+rT/LJGFFtthtTeW/Rg1Q7BS0lRXVS/f9a0g29AQ==',
        login   => 'somebody',
    }
);
isa_ok( $saml, 'Google::SAMLResponse' );




