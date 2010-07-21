use strict;
use warnings;
use ExtUtils::MakeMaker;


WriteMakefile(
    NAME                => 'Google::SAML::Response',
    AUTHOR              => 'Manni Heumann <saml@lxxi.org>',
    LICENSE             => 'perl',
    VERSION_FROM        => 'lib/Google/SAML/Response.pm',
    ABSTRACT_FROM       => 'lib/Google/SAML/Response.pm',
    PL_FILES            => {},
    PREREQ_PM           => { 
            'Google::SAML::Request'     => 0,
            'Date::Format'              => 0,
            'Crypt::OpenSSL::RSA'       => 0,
            'Crypt::OpenSSL::DSA'       => 0,
            'Crypt::OpenSSL::Bignum'    => 0,
            'Digest::SHA'               => 0,
            'File::Which'               => 0,
            'Carp'                      => 0,
            'XML::CanonicalizeXML'      => 0,
            'Test::More'                => 0,
            'Test::Exception'           => 0,
    },
    dist                => { 
            COMPRESS => 'gzip -9f', 
            SUFFIX => 'gz', 
        },
    clean               => { 
            FILES => 'Google-SAML-Request-*' 
        },
    META_MERGE          => {
            resources => {
                repository =>  'http://github.com/mannih/cpan/tree/master/Google-SAML-Response/'
            }
    },
);
