package PlackX::Engine::Builder;
use strict;
use warnings;
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
    eval "use $middleware_name";
    die $@ if $@;

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
