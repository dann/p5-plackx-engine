use Test::Dependencies
    exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic PlackX::Engine/],
    style   => 'light';
ok_dependencies();
