use strict;
use warnings;
use Test::More qw/ no_plan /;
use lib './t';
use Fake::Context;

BEGIN { 
    use_ok 'Catalyst::View::HTML::Template::Advanced'
}

Catalyst::View::HTML::Template::Advanced->config( 
    extra_tmpl_path  =>  './t/test_tmpl',
);


my %expected = ( 
    urifor_something          => { type => 'VAR',  value => '/something'          },
    urifor_something_or_other => { type => 'VAR',  value => '/something/or/other' },
    nourifor_something        => { type => 'VAR',  value => ''                    },
    content_template_content  => { type => 'VAR',  value => 'foo!'                },
    css_includes              => { type => 'LOOP', value => ''                    },
    js_includes               => { type => 'LOOP', value => ''                    },
    array_test                => { type => 'LOOP', value => '1 /action 2 /action '},
);

test_process();
test_create_template();


sub test_create_template {
    my $v = Catalyst::View::HTML::Template::Advanced->new();
    isa_ok( $v, 'Catalyst::View::HTML::Template::Advanced' );

    my $c = Fake::Context->new;
    $c->{ stash }->{ array_test } = [ { somevar => 1 }, { somevar => 2 } ];
    my $tmpl = $v->_create_template( $c, 'wrappers/full.html' );
    ok( $tmpl, 'got a template' );

    my %tmpl_vars;
    @tmpl_vars{ $tmpl->query() } = ();

    foreach my $e ( keys %expected ) {
        ok( exists $tmpl_vars{ $e }, "$e exists" );
        is( $tmpl->query( name => $e ), $expected{ $e }->{ type }, "$e is a $expected{$e}->{type}" );
    }
}


sub test_process {
    my $v = Catalyst::View::HTML::Template::Advanced->new();
    isa_ok( $v, 'Catalyst::View::HTML::Template::Advanced' );

    my $c = Fake::Context->new;
    $c->{ stash }->{ array_test } = [ { somevar => 1 }, { somevar => 2 } ];
    ok( $v->process( $c ), 'process returns true' );
    my $b = $c->_get_body;

    my @lines = split /\n/, $b;

    foreach my $l ( @lines ) {
        ok( $l=~ m/(.+): (.*)/, "$l parses" );
        my ( $var, $val ) = ( $1, $2 );
        ok( exists $expected{ $var }, "We were expecting $var." );
        is( $val, $expected{ $var }->{ value }, " and we got what we expected." );
    }
}


