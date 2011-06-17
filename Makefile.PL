use inc::Module::Install;
name 'JacKick';
all_from 'lib/JacKick.pm';

requires 'Plack'                     => 0;
requires 'namespace::clean'          => 0.14;
requires 'Router::Simple'            => 0.09;
requires 'HTML::Shakan'              => 0.07;
requires 'Scalar::Util'              => 1.23;
requires 'Module::Pluggable::Object' => 3.9;
requires 'Log::Minimal'              => 0.08;
requires 'Sub::Args'                 => 0.08;

tests_recursive 't/';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
