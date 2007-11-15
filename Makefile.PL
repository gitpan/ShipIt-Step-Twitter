use inc::Module::Install;
include 'Module::AutoInstall';

name 'ShipIt-Step-Twitter';
all_from 'lib/ShipIt/Step/Twitter.pm';
perl_version '5.006';

requires 'Net::Twitter';
requires 'ShipIt';
requires 'YAML';

build_requires 'Test::More' => '0.70';

# feature 'Generated documentation',
#     - default => 1,
#     'Pod::Generated' => '0.02';

process_templates(
    first_year => 2007,
    rest_from  => "$ENV{HOME}/.mitlib/standard_pod",
    start_tag  => '{%',
    end_tag    => '%}',
);

use_standard_tests(without => 'pod_coverage');
auto_install;
auto_include;
WriteAll;
