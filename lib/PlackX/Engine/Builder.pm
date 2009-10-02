package PlackX::Engine::Builder;
use strict;
use warnings;
use PlackX::Engine::Util;
use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors(qw/middlewares/);

sub new {
    my ( $class, $middlewares ) = @_;
    $middlewares ||= [];
    my $self = bless { middlewares => $middlewares }, $class;
    return $self;
}

sub add_middleware {
    my ( $self, $middleware_name, $middleware ) = @_;
    PlackX::Engine::Util::load_class($middleware_name);
    push @{ $self->{middlewares} }, $middleware;
}

sub to_app {
    my ( $self, $app ) = @_;
    for my $mw ( reverse @{ $self->{middlewares} } ) {
        $app = $mw->($app);
    }
    $app;
}

1;

__END__

=encoding utf-8

=head1 NAME

PlackX::Engine::Builder - request handler builder

=head1 SYNOPSIS

  use PlackX::Engine::Util;

=head1 DESCRIPTION

PlackX::Engine::Builder is request handler builder

=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
