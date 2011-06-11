use inc::Module::Install;
name 'Koashi';
all_from 'lib/Koashi.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
