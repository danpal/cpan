package Catalyst::View::HTML::Template::Advanced;
use strict;
use warnings;

use base 'Catalyst::View';
use HTML::Template;
use List::MoreUtils qw/ uniq /;

our $VERSION = '0.01_01';

=head1 NAME Yaatt::View::HTML

=head1 DESCRIPTION

This is based on L<Catalyst::View> and uses L<HTML::Template> to render HTML. It
is an alternative to L<Catalyst::View::HTML::Template> including a couple of
features that are not included in that very simple View module: 

=over

=item Wrappers

I wanted a system that uses a wrapper around the actual content so the
individual templates don't have to bring along the html-head, the navigation
section and everything else that gets shared by all or most of your templates.

=item CSS/JS includes

I wanted the ability to programmatically include certain stylesheets and
javascript files.  While it is certainly debatetable whether a controller
should even know about those, a wrapper system with a html-head section shared
across templates made this step necessary.

=item More cleverness

When not using TT, I found myself stuffing my controllers with stuff like
C<$c-E<gt>stash( foo_link =E<gt> $c-E<gt>uri_for( 'foo' ))>. That wasn't much
fun and it was easy to simply let the HTML view do that work for me.

=back

=head1 SYNOPSIS

root/tmpl/wrappers/full.html:

 <html>
  <head>
    <title><TMPL_VAR title></title>
    <TMPL_LOOP js_includes>
    <script type="text/javascript" src="<TMPL_VAR path"></script></TMPL_LOOP>
    <TMPL_LOOP css_includes>
    <link href="<TMPL_VAR path>" rel="stylesheet" /></TMPL_LOOP>
  </head>
  <body>
    <div id="navigation">
      <ul>
      ....
      </ul>
    </div>
    <div id="content">
      <TMPL_VAR content_template_content>
    </div>
    <div id="footer">
      Copyright by someone in some year
    </div>
  </body>
 </html>

root/tmpl/foo/bar.html:

  <p><TMPL_VAR msg></p>
  <p><a href="<TMPL_VAR urifor_bar_foo">Click here to continue</p>

and in lib/MyApp/Controller/Foo.pm:

  sub bar :Local {
      my ( $self, $c ) = @_;
      $c->stash( msg          => 'this is just a test';
      $c->stash( css_includes => [ 'main.css' ] );
      $c->stash( js_includes  => [ 'jquery.js' ] );
  }

As you can see, the biggest part is the HTML. But the biggest part of that goes in 
the wrapper where it can be reused for all your templates. You should also be able to
see that the variable C<urifor_bar_foo> wasn't set in the controller. 

=head1 USAGE

This module assumes that the templates can be found in C<root/tmpl>. It is also
assumed, that there is a wrapper template that provides the basic html
structure for each output page. That master container is just another template
that gets rendered by L<HTML::Template>. The rendered content of the actual
templates (those requested by the controller modules), gets inserted into the
wrapper by means of a template variable named C<content_template_content>. That
name should be peculiar enough to avoid any name clashes.

=head2 wrappers

Wrappers are searched for in the C<root/tmpl/wrappers> directory.

The name of the default wrapper is C<full.html>.  Should any page need a different
wrapper, the stash variable C<tmpl_wrapper> is used to determine
its name.

=head2 Javascript and stylesheets

If you need the rendered HTML to include a javascript file or a stylesheet, just
use the C<js_includes> or C<css_includes> stash variables. The view expects both
variables to contain a reference to an array. Example:

 $c->stash( js_includes => [ 'some/path/jquery.js', 'some/other/path/flot.js' ]

The paths are relative to the C<root/static/js> and C<root/static/css> directories,
respectively.

=head2 Magic template variables

Currently, there is only one magic template variable that you don't have to
set in your code, but which will be taken care of here: the C<urifor_foo> variable.

Here are two examples:

The variable C<urifor_something> found in a template (either wrapper or content
template), will be replaced by whatever the context object will return for
C<uri_for( '/something' )>. And the variable
C<urifor_something_completely_different> will be replaced by C<$c-E<gt>uri_for(
'/something/completely/different' )>. This is also valid for variables found in
template loops, but currently only on the first level, i.e. loops inside loops
will not be searched for those special variables.

=head2 Overriding the default templates with your own

To allow users of your catalyst application to override (some of) your templates,
you can set an extra template search path in the configuration where those custom
templates can be put. For example:

 View::HTML:
     extra_tmpl_path: /foo/bar/baz

Any templates found in /foo/bar/baz will then be preferred over those in root/tmpl

=head1 SEE ALSO

L<Catalyst::View::HTML::Template>

=head1 AUTHOR

Manni Heumann, C<manni@cpan.org>

=head1 COPYRIGHT

This program is free software. You can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

sub process {
    my ( $self, $c ) = @_;

    $self->{ root_path } = $c->path_to( 'root' ) . '/tmpl';
    $c->log->debug( "Template root path is $self->{ root_path }" );
    if ( defined $self->{ extra_tmpl_path } ) {
        $c->log->info( "Extra template path: $self->{ extra_tmpl_path }." );
    }

    my $file = $c->stash->{template} || $c->req->match . '.html';
    $c->log->debug( "Using '$file' as content template" );
    my $content_tmpl = $self->_create_template( $c, $file );
    my $content      = $content_tmpl->output;

    my $wrapper = $c->stash->{tmpl_wrapper} || 'full.html';
    $c->log->debug( "Using '$wrapper' as wrapper template." );
    my $wrapper_tmpl = $self->_create_template( $c, 'wrappers/' . $wrapper );
    $self->_insert_css_and_js_includes( $c, $wrapper_tmpl );
    $wrapper_tmpl->param( content_template_content => $content );

    unless ( $c->response->headers->content_type ) {
        $c->response->headers->content_type('text/html; charset=utf-8');
    }

    $c->response->body( $wrapper_tmpl->output );

    return 1;
}


sub _create_template {
    my $self = shift;
    my $c    = shift;
    my $file = shift;

    my $tmpl = HTML::Template->new( 
        cache               => 1,
        filename            => $file,
        path                => [ $self->{extra_tmpl_path}, $self->{ root_path } ],
        die_on_bad_params   => 0,
    );

    # First, look at the template variables that are not loops and change their
    # value where appropriate
    # (we are looking through the template, but we write to the stash!) 
    my @tmpl_vars = grep { $tmpl->query( name => $_ ) ne 'LOOP' } $tmpl->query();
    my $changed   = $self->_check_for_uris( $c, \@tmpl_vars );
    foreach my $k ( %$changed ) {
        $c->stash->{ $k } = $changed->{ $k };
    }

    # Now look at the loops,
    my @tmpl_loops = grep { $tmpl->query( name => $_ ) eq 'LOOP' } $tmpl->query();
    foreach my $l ( @tmpl_loops ) {

        # loop through the values in each loop
        my @vars = $tmpl->query( loop => $l );
        my $changed = $self->_check_for_uris( $c, \@vars );
        # and merge the changes to the stash
        foreach my $k ( %$changed ) {
            my $stashed = $c->stash->{ $l };
            foreach my $i ( @$stashed ) {
                $i->{ $k } = $changed->{ $k };
            }
        }
    }
    $tmpl->param( $c->stash );

    return $tmpl;
}


sub _check_for_uris {
    my $self   = shift;
    my $c      = shift;
    my $params = shift;
    my $always_change = shift;

    my $changed = {};
    foreach my $var ( @$params ) {
        if ( $var =~ m/^urifor_/ ) {
            my $action = '/' . join '/', $var =~ m/_([^_]+)/g;
            my $uri = $c->uri_for( $action );
            $changed->{ $var } = $uri;
        }
    }

    return $changed;
}

sub _insert_css_and_js_includes {
    my ( $self, $c, $wrapper_tmpl ) = @_;

    my $js_path  = $c->uri_for( '/static/js' ) . '/';
    my $js_loop  = [ map { { path => $js_path . $_ } } uniq @{ $c->stash->{js_includes} } ];
    delete $c->stash->{js_includes};
    $wrapper_tmpl->param( js_includes  => $js_loop  );

    my $css_path = $c->uri_for( '/static/css' ) . '/';
    my $css_loop = [ map { { path => $css_path . $_ } } uniq @{ $c->stash->{css_includes} } ];
    delete $c->stash->{css_includes};
    $wrapper_tmpl->param( css_includes => $css_loop );
}


1;
