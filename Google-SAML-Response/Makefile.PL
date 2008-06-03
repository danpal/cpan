use strict;
use warnings;
use ExtUtils::MakeMaker;


    WriteMakefile(
    NAME                => 'Google::SAMLResponse',
    AUTHOR              => 'Manni Heumann <saml@lxxi.org>',
    VERSION_FROM        => 'lib/Google/SAMLResponse.pm',
    ABSTRACT_FROM       => 'lib/Google/SAMLResponse.pm',
    PL_FILES            => {},
    PREREQ_PM           => { 
            'Date::Format'              => 0,
            'Crypt::OpenSSL::RSA'   => 0,
            'MIME::Base64'              => 0,
            'Digest::SHA'               => 0,
            'Compress::Zlib'            => 0,
            'Carp'                      => 0,
            'XML::CanonicalizeXML'      => 0,
            'Test::More'                => 0,
            'Test::Exception'           => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Google-SAMLResponse-*' },
);
