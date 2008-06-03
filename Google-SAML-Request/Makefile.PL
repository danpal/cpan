use strict;
use warnings;
use ExtUtils::MakeMaker;


    WriteMakefile(
    NAME                => 'Google::SAML::Request',
    AUTHOR              => 'Manni Heumann <saml@lxxi.org>',
    VERSION_FROM        => 'lib/Google/SAML/Request.pm',
    ABSTRACT_FROM       => 'lib/Google/SAML/Request.pm',
    PL_FILES            => {},
    PREREQ_PM           => { 
            'MIME::Base64'              => 0,
            'Compress::Zlib'            => 0,
            'Carp'                      => 0,
            'Test::More'                => 0,
            'Test::Exception'           => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Google-SAML-Request-*' },
);
