use inc::Module::Install;
name 'Koashi';
all_from 'lib/Koashi.pm';

requires 'Plack'                     => 0;
requires 'namespace::autoclean'      => 0;
requires 'Router::Simple'            => 0;
requires 'HTML::Shakan'              => 0;
requires 'Scalar::Util'              => 0;
requires 'Module::Pluggable::Object' => 0;
requires 'Log::Minimal'              => 0;

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
