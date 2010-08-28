
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Data::Dump' => '0',
    'English' => '0',
    'File::Find' => '0',
    'File::Temp' => '0',
    'FindBin' => '0',
    'Module::Build' => '0.3601',
    'Test::Exception' => '0',
    'Test::More' => '0.88'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Various tools for working with __DATA__',
  'dist_author' => [
    'Kent Fredric <kentnl@cpan.org>'
  ],
  'dist_name' => 'Package-Stash-Data',
  'dist_version' => '0.01000002',
  'license' => 'perl',
  'module_name' => 'Package::Stash::Data',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Package::Stash' => '0'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
