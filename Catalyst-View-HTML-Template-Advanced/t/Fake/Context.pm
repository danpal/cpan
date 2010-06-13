package Fake::Context;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self  = {
        stash  => {},
        action => 'index',
        content_type => 'text/html',
        body   => '',
    };

    return bless $self, $class;
}

sub log {
    return shift;
}
sub info {}
sub debug {}

sub path_to {
    return '.';
}

sub uri_for {
    my $self   = shift;
    my $action = shift;

    return $action;
}

sub stash {
    my $self = shift;
    return $self->{ stash };
}

sub req {
    return shift;
}

sub _set_action {
    my $self   = shift;
    my $action = shift;

    $self->{ action } = $action;
}

sub match {
    my $self = shift;
    return $self->{ action };
}


sub response {
    return shift;
}

sub headers {
    return shift;
}

sub _set_content_type {
    my $self = shift;
    my $ct   = shift;

    $self->{ content_type } = $ct;
}

sub content_type {
}

sub body {
    my $self = shift;
    my $body = shift;

    $self->{ body } = $body;
}

sub _get_body {
    my $self = shift;
    return $self->{ body };
}

1;
