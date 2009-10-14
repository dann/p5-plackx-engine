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
    {   
        request_handler => $request_handler,
        middlewares     => [
            { module => "Plack::Middleware::AccessLog::Timed" },
            { module => "Plack::Middleware::Static" }
        ],
    }
);

my $handler = $engine->psgi_handler;
