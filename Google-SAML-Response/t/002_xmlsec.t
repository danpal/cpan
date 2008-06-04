# -*- perl -*-

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
    use_ok( 'Google::SAML::Response' );
}

if ( `xmlsec1` ) {
}

SKIP: {
    skip "xmlsec1 not installed", 3 unless `xmlsec1`;

    my $request = 'eJxdkE1PwzAMhs/9F1XubcM00IjWTQOEmDTQtA8O3NrEa7M1donTjZ9P2UAgrraf1489nn64Jj6CZ0uYi6tUihhQk7FY5WK7eUxGYjoZc+GaVs26UOMK3jvgEEc9iKzOnVx0HhUVbFlh4YBV0Go9e16oQSpV6ymQpkZE84dc7Nqign17KGtnzI5MUzrc1aayaB0cLOiD3ZcAVsTR649Wn9LDzB3MkUOBoS9JeZPI60QONnKkhrdqKN9EtPxedWfxcsE/r/SvV3kZYvW02SyTFRjrQYdzyNEa8C89kYuKqGog1eRENGMGH3qle0LuHPg1+KPVsF0tclGH0LLKstPplP5CWU0cwGQt09erDDhKEUJWaBbZ5BPy1YRc';
    my $saml = Google::SAML::Response->new( { key => 't/rsa.private.key', login => 'someone', request => $request } );
    my $xml = $saml->get_response_xml();
    ok( $xml, "Got XML for the response" );
    if ( open my $XML, '>', 'tmp.xml' ) {
        print $XML $xml;
        close $XML;
    }
    else {
        ok( 0, "Could not open temporary file tmp.xml: $!" );
    }
    my $verify_response = `xmlsec1 --verify tmp.xml 2>&1`;
    ok( $verify_response =~ m/^OK/, "Response is OK for xmlsec1" );
    unlink 'tmp.xml';
}
