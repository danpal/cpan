use strict;
use warnings;
use ExtUtils::MakeMaker;


WriteMakefile(
    NAME                => 'Google::SAML::Request',
    AUTHOR              => 'Manni Heumann <saml@lxxi.org>',
    LICENSE             => 'perl',
    VERSION_FROM        => 'lib/Google/SAML/Request.pm',
    ABSTRACT_FROM       => 'lib/Google/SAML/Request.pm',
    PL_FILES            => {},
    PREREQ_PM           => { 
            'URI::Escape'     => 0,
            'MIME::Base64'    => 0,
            'Compress::Zlib'  => 0,
            'Date::Format'    => 0,
            'XML::Simple'     => 0,
            'CGI'             => 0,
            'Carp'            => 0,
            'Test::More'      => 0,
            'Test::Exception' => 0,
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
                repository =>  'http://github.com/mannih/cpan/tree/master/Google-SAML-Request/'
            }
    },
);
