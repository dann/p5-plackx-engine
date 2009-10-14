#!/usr/bin/env perl
use strict;
use warnings;
use PlackX::Engine;
use Plack::Response;

my $request_handler = sub {
    my $req = shift;
    my $res = Plack::Response->new;
    $res->code(200);
    $res->header( 'Content-Type' => 'text/html' );
    $res->body("Hello World");
    return $res;
};

my $engine = PlackX::Engine->new(
    {   server => {
            module => 'Standalone',
            args   => {
                port => 3000,
                host => 'localhost',
            },
        },
        request_handler => $request_handler,
        middlewares     => [
            { module => "Plack::Middleware::AccessLog::Timed" },
            { module => "Plack::Middleware::Static" }
        ],
    }
);

my $handler = $engine->run;
