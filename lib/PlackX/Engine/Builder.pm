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
