use strict;
use Test::Base;
use PlackX::Engine;
use Plack::Response;

filters {
    app         => 'eval',
    header      => 'yaml',
    env         => 'yaml',
    res_headers => 'yaml',
    res_body    => 'yaml',
};

plan tests => 2 * blocks;

run {
    my $block = shift;

    my $request_handler = sub {
        my $req = shift;
        my $res = Plack::Response->new;
        $res->code( $block->status );
        $res->header( %{ $block->header } );
        $res->body( $block->body );
        return $res;
    };

    my $engine = PlackX::Engine->new(
        {   server => {
                module => 'ServerSimple',
                args   => {
                    port => 3000,
                    host => 'localhost',
                },
            },
            request_handler => $request_handler,
        }
    );

    my $handler = $engine->psgi_handler;

    my $res = $handler->( $block->env );

    is $res->[0],        $block->res_status;
    is_deeply $res->[1], $block->res_headers;

};

__END__

=== 200 response
--- status
200
--- header
Content-Type: text/plain
--- body
OK
--- env
REQUEST_METHOD: GET
--- res_headers
- Content-Type
- text/plain
--- res_status
200
