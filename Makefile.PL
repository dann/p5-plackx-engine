use inc::Module::Install;
name 'PlackX-Engine';
all_from 'lib/PlackX/Engine.pm';

requires(
    "Class::Accessor::Fast" => 0,
    "Plack"                 => 0,
    "Plack::Request"        => 0,
);
test_requires(
    'Test::More'           => 0,
    'Test::LoadAllModules' => 0,
);
use_test_base;
auto_include;
WriteAll;
