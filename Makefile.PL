use inc::Module::Install;
name 'Koashi';
all_from 'lib/Koashi.pm';

requires 'Plack'                     => 0;
requires 'namespace::autoclean'      => 0;
requires 'Router::Simple'            => 0.09;
requires 'HTML::Shakan'              => 0.07;
requires 'Scalar::Util'              => 1.23;
requires 'Module::Pluggable::Object' => 3.9;
requires 'Log::Minimal'              => 0.08;

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
