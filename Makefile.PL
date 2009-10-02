use inc::Module::Install;
name 'PlackX-Engine';
all_from 'lib/PlackX/Engine.pm';

requires(
    "Plack"                 => 0,
    "Class::Accessor::Fast" => 0,
);
test_requires( 'Test::More' => 0, );
use_test_base;
auto_include;
WriteAll;
