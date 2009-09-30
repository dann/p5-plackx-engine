use PlackX::Engine;
use Plack::Response;

my $request_handler = sub {
    my $req = shift;
    my $res = Plack::Response->new;
    $res->code(200);
    $res->header( 'Content-Type' => 'text/html' );
    $res->body( ["Hello World"] );
    $res->finalize;
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
        middlewares =>
            [ { module => "AccessLog::Timed" }, { module => "Static" } ],
    }
);

my $handler = $engine->handler;
