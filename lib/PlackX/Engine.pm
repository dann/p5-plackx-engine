package PlackX::Engine;
use strict;
use warnings;
use 5.008_001;
our $VERSION = '0.01';

use Plack::Loader;
use Plack::Builder;
use PlackX::Engine::Util;
use Carp ();

use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors(qw/server middlewares request_handler request_class/);

sub new {
    my ( $class, $args ) = @_;
    Carp::croak 'request_handler is required.'
        unless $args->{request_handler};
    my $self = bless {
        server          => $args->{server},
        request_handler => $args->{request_handler},
        middlewares     => $args->{middlewares} || [],
        request_class   => $args->{request_class} || 'Plack::Request',
    }, $class;
    $self->_init;
    $self;
}

sub _init {
    my $self = shift;
    PlackX::Engine::Util::load_class( $self->{request_class} );
}

sub run {
    my $self = shift;
    Carp::croak 'server is required' unless $self->{server};
    Carp::croak '{server}->{module} is required'
        unless $self->{server}->{module};

    my $server_instance
        = $self->_build_server_instance( $self->{server}->{module},
        $self->{server}->{args} );
    my $request_handler = $self->psgi_handler;
    $server_instance->run($request_handler);
}

sub psgi_handler {
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
    my $builder = Plack::Builder->new;
    for my $middleware ( @{ $self->{middlewares} } ) {
        $builder->add_middleware( $middleware->{module},
            %{ $middleware->{opts} || {} } );
    }
    $builder->to_app($request_handler);
}

sub build_request {
    my ( $self, $env ) = @_;
    $self->{request_class}->new($env);
}

1;

__END__

=encoding utf-8

=head1 NAME

PlackX::Engine - simple request wrapper for Plack

=head1 SYNOPSIS

* case1: as standalone

  use PlackX::Engine;
  use Plack::Response;

  my $request_handler = sub {
      my $req = shift;
      my $res = Plack::Response->new;
      $res->code(200);
      $res->header( 'Content-Type' => 'text/html' );
      $res->body( "Hello World" );
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
          request_class => 'Plack::Request', # optional
      }
  );
 
  $engine->run;

* case2: as psgi handler builder
just create engine and return psgi_handler in example.psgi file
 
  use PlackX::Engine;
  use Plack::Response;

  my $request_handler = sub {
      my $req = shift;
      my $res = Plack::Response->new;
      $res->code(200);
      $res->header( 'Content-Type' => 'text/html' );
      $res->body( "Hello World" );
  };
  
  my $engine = PlackX::Engine->new(
      {
          request_handler => $request_handler,
          middlewares => [
              { module => "Plack::Middleware::AccessLog::Timed" },
              { module => "Plack::Middleware::Static" }
          ],
      }
  );
  my $psgi_handler = $engine->psgi_handler;

run your request handler with psgi

  plackup -app example.psgi

=head1 DESCRIPTION

PlackX::Engine is the simple request wrapper for Plack.
You want to wrap psgi env with request and response if you make application with Plack.
You don't need to  wrap psgi env with the request and finaize response if you use this module.

=head1 SOURCE AVAILABILITY

This source is in Github:

  http://github.com/dann/p5-plackx-engine

=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
