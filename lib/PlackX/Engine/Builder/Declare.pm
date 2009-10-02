package PlackX::Engine::Builder::Declare;
use strict;
use PlackX::Engine::Builder;

sub import {
    my $caller = caller;

    no strict 'refs';
    no warnings 'redefine';

    *{ $caller . '::builder' } = \&builder;
    *{ $caller . '::enable' }  = \&enable;
}

sub _stub {
    my $name = shift;
    return sub { Carp::croak "Can't call $name() outside routing block" };
}

{
    my @Declarations = qw(builder enable);
    for my $keyword (@Declarations) {
        no strict 'refs';
        *$keyword = _stub $keyword;
    }
}

sub builder(&) {
    my $block = shift;

    my $builder = PlackX::Engine::Builder->new;
    no warnings 'redefine';

    local *enable = enable_middleware($builder);

    my $app = $block->();
    $builder->to_app($app);
}

sub enable_middleware {
    my $builder = shift;

    return sub {
        my ( $middleware, @args ) = @_;
        $builder->add_middleware( $middleware,
            sub { $middleware->wrap( @args, $_[0] ); } );
    };
}

1;

__END__
