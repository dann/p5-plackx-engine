package PlackX::Engine;
use strict;
use warnings;
use 5.008_001;
our $VERSION = '0.01';

use Class::Accessor "antlers";
use Plack::Loader;
use Plack::Request;
use PlackX::Engine::Builder;

has server          => ( is => "rw", isa => "HashRef" );
has request_handler => ( is => "rw", isa => "CodeRef" );
has middlewares     => ( is => "rw", isa => "ArrayRef" );

sub run {
    my $self = shift;
    my $server_instance
        = $self->_build_server_instance( $self->{server}->{module},
        $self->{server}->{args} );
    my $request_handler = $self->handler;
    $server_instance->run($request_handler);
}

sub handler {
    shift->_build_request_handler;
}

sub _build_server_instance {
    my ( $class, $server, $args ) = @_;
    Plack::Loader->load( $server, %$args );
}

sub _build_request_handler {
    my $self = shift;
    my $app  = $self->_build_app;
    $self->_wrap_with_middlewares($app);
}

sub _build_app {
    my $self = shift;
    return sub {
        my $env = shift;
        my $req = $self->build_request($env);
        my $res = $self->{request_handler}->($req);
        $res->finalize;
    };
}

sub _wrap_with_middlewares {
    my ( $self, $request_handler ) = @_;
    my $builder = PlackX::Engine::Builder->new;

    # orz. this code should be moved to PlackX::Engine::Builder
    for my $middleware ( @{ $self->{middlewares} || [] } ) {
        my $middleware_name = $middleware->{module};
        $builder->add_middleware(
            $middleware_name,
            sub {
                $middleware_name->wrap( @{ $middleware->{args} || [] },
                    $_[0] );
            }
        );
    }
    $builder->to_app($request_handler);
}

sub build_request {
    my ( $self, $env ) = @_;
    Plack::Request->new($env);
}

1;

__END__

=encoding utf-8

=head1 NAME

PlackX::Engine -

=head1 SYNOPSIS

  use PlackX::Engine;
  use Plack::Response;

  my $request_handler = sub {
      my $req = shift;
      my $res = Plack::Response->new;
      $res->code(200);
      $res->header( 'Content-Type' => 'text/html' );
      $res->body( ["Hello World"] );
  };
  
  my $engine = PlackX::Engine->new(
      {
          server => {
              module => 'ServerSimple',
              args   => {
                  port => 3000,
                  host => 'localhost',
              },
          },
          request_handler => $request_handler,
          middlewares => [
              { module => "Plack::Middleware::AccessLog::Timed" },
              { module => "Plack::Middleware::Static" }
          ],
      }
  );
  
  $engine->run;

=head1 DESCRIPTION

PlackX::Engine is

=head1 SOURCE AVAILABILITY

This source is in Github:

  http://github.com/dann/

=head1 CONTRIBUTORS

Many thanks to:


=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
