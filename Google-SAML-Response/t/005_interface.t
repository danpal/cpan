# -*- perl -*-

use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;

BEGIN {
    use_ok( 'Google::SAMLResponse' );
}

my $request = 'eJxdkE1PwzAMhs/9F1XubcM00IjWTQOEmDTQtA8O3NrEa7M1donTjZ9P2UAgrraf1489nn64Jj6CZ0uYi6tUihhQk7FY5WK7eUxGYjoZc+GaVs26UOMK3jvgEEc9iKzOnVx0HhUVbFlh4YBV0Go9e16oQSpV6ymQpkZE84dc7Nqign17KGtnzI5MUzrc1aayaB0cLOiD3ZcAVsTR649Wn9LDzB3MkUOBoS9JeZPI60QONnKkhrdqKN9EtPxedWfxcsE/r/SvV3kZYvW02SyTFRjrQYdzyNEa8C89kYuKqGog1eRENGMGH3qle0LuHPg1+KPVsF0tclGH0LLKstPplP5CWU0cwGQt09erDDhKEUJWaBbZ5BPy1YRc';
my $saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );

isa_ok( $saml, 'Google::SAMLResponse' );

$saml = Google::SAMLResponse->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );

ok( $saml->{service_url} eq 'https://www.google.com/hosted/psosamldemo.net/acs', 'Decoded request contains login url' );
ok( $saml->{inflated_SAMLRequest} =~ m/^<\?xml /, 'Decoded request contains start of xml' );
ok( $saml->{inflated_SAMLRequest} =~ m{/>$}, 'Decoded request contains end of xml' );

