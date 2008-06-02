#  Copyright (c) 2008 Manni Heumann. All rights reserved.
#
#  This program is free software; you can redistribute it and/or
#  modify it under the same terms as Perl itself.

package Google::SAMLResponse;

=head1 NAME

Google::SAMLResponse - Generate signed XML documents as SAMLResponses for Google's
SSO implementation

=head1 VERSION

You are currently reading the documentation for version 0.01

=head1 DESCRIPTION

Google::SAMLResponse can be used to generate a signed
xml document that is needed for logging your users into
Google using SSO.

For example, you have some sort of application that authenticates
users such as a web application. Your users should be able to use
some sort of Google service such as Google mail. Now when using
SSO with your Google partner account, Google will redirect users
to a URL that you can define. Behind this URL, you can have a script
that can authenticate users in your original framework, generate
a SAMLResponse for Google that you send to your users who then
submit it to Google. If everything works, users will then be logged
into a Google account and they don't even have to know their usernames
or passwords.

=head1 SYNOPSIS

 use Google::SAMLResponse;
 use CGI;

 # get SAMLRequest parameter:
 my $request = CGI->new()->param('SAMLRequest');

 # authenticate user
 ...

 # find our user's login for Google
 ...

 # Generate SAMLResponse
 my $saml = Google::SAMLResponse::new( key = $key, login => $login, request => $request );
 my $xml  = $saml->generate_signed_xml();

 # Alternatively, send a HTML page to the client that will redirect
 # her to Google. You have to extract the RelayState param from the cgi
 # environment first. $login_url is the URL your users use to log on to
 # Google.
 print $saml->get_google_form( $relayState, $login_url );

=head1 PREREQUISITES

You will need the following modules installed:

=over

=item * Crypt::OpenSSL::RSA

=item * XML::Canonical or XML::CanonicalizeXML

=item * MIME::Base64

=item * Digest::SHA

=item * Date::Format

=item * Compress::Zlib

=back


=head1 RESOURCES

=over

=item XML-Signature Syntax and Processing

http://www.w3.org/TR/xmldsig-core/

=item Google-Documentation on SSO and SAML

http://code.google.com/apis/apps/sso/saml_reference_implementation.html

=item XML Security Library

http://www.aleksey.com/xmlsec/

=back

=head1 METHODS

=cut

use strict;
use warnings;

use Crypt::OpenSSL::RSA;
use MIME::Base64;
use Digest::SHA qw/ sha1 /;
use Date::Format;
use Compress::Zlib;
use Carp;


our $VERSION = '0.01';

=head2 new

Creates a new object and needs to have all parameters needed to generate
the signed xml later on. Parameters are passed in as a hash-reference.

=head3 Required parameters

=over

=item * request => STRING

The SAML request, base64-encoded and all, just as retrieved from the GET
request your user contacted you with

=item * key => STRING

The path to your private key that will be used to sign the response. Currently,
only RSA keys are supported.

=item * login => STRING

Your user's login name with Google

=back

=head3 Optional parameters

=over

=item * ttl => INT

Time to live: Number of seconds your response should be valid. Default is two minutes.

=item * canonicalizer => STRING

The name of the module that will be used to canonicalize parts of our xml. Currently,
XML::Canonical and XML::CanonicalizeXML are supported. XML::CanonicalizeXML is the default.

=back

=cut


sub new {
    my $class = shift;

    my $params = shift;
    my $self = {};

    foreach my $required ( qw/ request key login / ) {
        if ( exists $params->{ $required } ) {
            $self->{ $required } = $params->{ $required };
        }
        else {
            confess "You need to provide the $required parameter!";
        }
    }

    bless $self, $class;

    if ( $self->_decode_saml_msg() && $self->_load_key() ) {

        $self->{ ttl } = exists $params->{ ttl } ? $params->{ ttl } : 60*2;
        $self->{ canonicalizer } = exists $params->{ canonicalizer } ? $params->{ canonicalizer } : 'XML::CanonicalizeXML';

        return $self;
    }
    else {
        return;
    }

}



sub _load_key {
    my $self = shift;
    my $file = $self->{ key };
    $self->{ rsa_key } = undef;

    if ( open my $KEY, '<', $file ) {
        my $text = '';
        local $/ = undef;
        $text = <$KEY>;
        close $KEY;
        my $rsaKey = Crypt::OpenSSL::RSA->new_private_key( $text );

        if ( $rsaKey ) {
            $self->{ rsa_key } = $rsaKey;

            my $bigNum = ( $rsaKey->get_key_parameters() )[1];
            my $bin = $bigNum->to_bin();
            $self->{exponent} = encode_base64( $bin, '' );

            $bigNum = ( $rsaKey->get_key_parameters() )[0];
            $bin = $bigNum->to_bin();
            $self->{modulus} = encode_base64( $bin, '' );

            return 1;
        }
        else {
            warn "did not get a new Crypt::OpenSSL::RSA object";
        }
    }
    else {
        confess "Could not load key $file: $!";
    }

    return;
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


=head2 get_response_xml

Generate the signed response xml and return it as a string

The method does what the w3c tells us to do (http://www.w3.org/TR/xmldsig-core/#sec-CoreGeneration):

3.1.1 Reference Generation

For each data object being signed:

1. Apply the Transforms, as determined by the application, to the data object.

2. Calculate the digest value over the resulting data object.

3. Create a Reference element, including the (optional) identification of the data object, any (optional) transform elements, the digest algorithm and the DigestValue. (Note, it is the canonical form of these references that are signed in 3.1.2 and validated in 3.2.1 .)

3.1.2 Signature Generation

1. Create SignedInfo element with SignatureMethod, CanonicalizationMethod and Reference(s).

2. Canonicalize and then calculate the SignatureValue over SignedInfo based on algorithms specified in SignedInfo.

3. Construct the Signature element that includes SignedInfo, Object(s) (if desired, encoding may be different than that used for signing), KeyInfo (if required), and SignatureValue.

=cut

sub get_response_xml {
    my $self = shift;

    # This is the xml response without any signatures or digests:
    my $xml = $self->_response_xml();

    # We now calculate the SHA1 digest of the canoncial response xml
    my $canonical = $self->_canonicalize_xml( $xml );

    my $bin_digest = sha1( $canonical );
    my $digest = encode_base64( $bin_digest, '' );

    # Create a xml fragment containing the digest:
    my $digest_xml = $self->_reference_xml( $digest );

    # create a xml fragment consisting of the SignedInfo element
    my $signed_info = $self->_signedinfo_xml( $digest_xml );

    # We now calculate a signature over the canonical SignedInfo element
    $self->{rsa_key}->use_pkcs1_padding();
    $canonical = $self->_canonicalize_xml( $signed_info );
    my $bin_signature = $self->{rsa_key}->sign( $canonical );
    my $signature = encode_base64( $bin_signature, "\n" );

    # With the signature value and the signedinfo element, we create
    # a Signature element:
    my $signature_xml = $self->_signature_xml( $signed_info, $signature );

    # Now insert the signature xml into our response xml
    $xml =~ s{</Assertion>}{</Assertion>$signature_xml};

    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" . $xml;
}


sub _signature_xml {
    my $self = shift;
    my $signed_info = shift;
    my $signature_value = shift;

    return qq{<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
            $signed_info
            <SignatureValue>$signature_value</SignatureValue>
            <KeyInfo>
                <KeyValue>
                    <RSAKeyValue>
                        <Modulus>$self->{modulus}</Modulus>
                        <Exponent>$self->{exponent}</Exponent>
                    </RSAKeyValue>
                </KeyValue>
            </KeyInfo>
        </Signature>};
}



sub _signedinfo_xml {
    my $self = shift;
    my $digest_xml = shift;

    return qq{<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:xenc="http://www.w3.org/2001/04/xmlenc#">
                <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments" />
                <SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />
                $digest_xml
            </SignedInfo>};
}


sub _reference_xml {
    my $self = shift;
    my $digest = shift;

    return qq {<Reference URI="">
                        <Transforms>
                            <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
                        </Transforms>
                        <DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />
                        <DigestValue>$digest</DigestValue>
                    </Reference>};
}



sub _canonicalize_xml {
    my $self = shift;
    my $xml  = shift;

    if ( $self->{canonicalizer} eq 'XML::Canonical' ) {
        require XML::Canonical;
        my $xmlcanon = XML::Canonical->new( comments => 1 );
        return $xmlcanon->canonicalize_string( $xml );
    }
    elsif ( $self->{ canonicalizer } eq 'XML::CanonicalizeXML' ) {
        require XML::CanonicalizeXML;
        my $xpath = '<XPath>(//. | //@* | //namespace::*)</XPath>';
        return XML::CanonicalizeXML::canonicalize( $xml, $xpath, [], 0, 0 );
    }
    else {
        confess "Unknown XML canonicalizer module.";
    }
}

sub _response_xml {
    my $self = shift;

    # A 160-bit string containing a set of randomly generated characters.
    # The ID MUST start with a character
    my $response_id   = sprintf 'GOSAML0d%04d', time, rand(10000);

    # A timestamp indicating the date and time that the SAML response was generated
    # Bsp: 2006-08-17T10:05:29Z
    # All SAML time values have the type xs:dateTime, which is built in to the W3C XML Schema Datatypes
    # specification [Schema2], and MUST be expressed in UTC form, with no time zone component.
    my $issue_instant = time2str( "%Y-%m-%dT%XZ", time, 'UTC' );

    # A 160-bit string containing a set of randomly generated characters.
    my $assertion_id = sprintf 'GOSAML%010d%04d', time, rand(10000);

    # The username for the authenticated user.
    my $username = $self->{login};

    # A timestamp identifying the date and time after which the SAML response is deemed invalid.
    my $best_before = time2str( "%Y-%m-%dT%XZ", time + $self->{ttl}, 'UTC' );

    # A timestamp indicating the date and time that you authenticated the user.
    my $authn_instant = $issue_instant;

    return qq{<samlp:Response xmlns="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:xenc="http://www.w3.org/2001/04/xmlenc#" ID="$response_id" IssueInstant="$issue_instant" Version="2.0">
        <samlp:Status>
           <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"></samlp:StatusCode>
        </samlp:Status>
        <Assertion ID="$assertion_id" IssueInstant="$issue_instant" Version="2.0">
           <Issuer>https://www.opensaml.org/IDP</Issuer>
           <Subject>
              <NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">$username</NameID>
              <SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"></SubjectConfirmation>
           </Subject>
           <Conditions NotBefore="$issue_instant" NotOnOrAfter="$best_before"> </Conditions>
           <AuthnStatement AuthnInstant="$authn_instant">
              <AuthnContext>
                 <AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:Password</AuthnContextClassRef>
              </AuthnContext>
           </AuthnStatement>
        </Assertion>
    </samlp:Response>
};
}

=head2 get_google_form

This function will give you a complete HTML page (including the HTTP headers) that
you can send to clients to have them redirected to Google.

After all the hi-tec stuff Google wants us to do to parse their request and
generate a response, this is where it gets low-tec and messy. We are supposed
to give clients a html page that contains a hidden form that uses Javascript
to post that form to Google. Ugly, but it works. The form will contain a textarea
containing the response xml and a textarea containing the relay state.

Hence the first required argument: the RelayState parameter out of the user's GET request

The second parameter is the Login-URL for you users at Google. This is where the
form will be posted to (the action parameter).

=cut

sub get_google_form {
    my $self = shift;
    my $rs   = shift;
    my $url  = shift;

    my $output = "Content-type: text/html\n\n";
    $output .= "<html><head></head><body onload='javascript:document.acsForm.submit()'>\n";

    my $xml = $self->get_response_xml();

    $output .= qq|
        <div style="display: none;">
        <form name="acsForm" action="$url" method="post">
            <textarea name="SAMLResponse">$xml</textarea>
            <textarea name="RelayState">$rs</textarea>
            <input type="submit" value="Submit SAML Response" />
        </form>
        </div>
    |;

    $output .= "</body></html>\n";

    return $output;
}



=head1 REMARKS

Coming up with a valid response for a SAMLRequest is quite tricky. The simplest
way to go is to use the xmlsec1 program distributed with the XML Security Library.
Google seems to use that program itself. However, I wanted to have a Perlish way
of comming up with the response. Testing your computed response is best done
against xmlsec1: If your response is stored in the file test.xml, you can simply do:

 xmlsec1 --verify --store-references --store-signatures test.xml > debug.txt

This will give you a file debug.txt with lots of information, most importantly it
will give you the canonical xml versions of your response and the References
element. If you canonical xml of these two elements isn't exactly like the one
in debug.txt, your response will not be valid.

This brings us to another issue: XML-canonicalization. There are currently two
modules on CPAN that promise to do the work for you: XML::CanonicalizeXML and
XML::Canonical. Both can be used with Google::SAMLResponse, however the default
is to use the former because it is easier to install. However, the latter's
interface is much cleaner and Perl-like than the interface of the former.

Both of these modules are tricky to install. XML::Canonical uses XML::GDOME
which has a stupid Makefile.PL that begs to be hacked because it insists on using the
exact version of gdome that was available when Makefile.PL was written and then
it still doesn't install without force. XML::CanonicalizeXML is much easier to
install, you just have to have the libxml development files installed so it
will compile.

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
