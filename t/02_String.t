use strict;
use warnings;

use Test::More tests => 2;    # last test to print
use Test::Exception;

use FindBin;
use lib "${FindBin::Bin}/lib";

use Data;
use Data::Dump qw( dump );
use Package::Stash::Data::String;

subtest 'existing data' => sub {
  plan tests              => 2;
  subtest 'content_array' => sub {
    plan tests => 3;
    for ( 1 .. 3 ) {
      is_deeply(
        [ Package::Stash::Data::String->content_array('Data') ],
        [ ( "Hello World.\n", "\n", "\n", "This is a test file.\n" ) ],
        'Depth Compare'
      );
    }
  };

  subtest 'content' => sub {
    plan tests => 3;
    for ( 1 .. 3 ) {
      is( Package::Stash::Data::String->content('Data'), "Hello World.\n\n\nThis is a test file.\n", 'String Compare' );
    }

  };

};

subtest 'non-existing data' => sub {
  plan tests              => 2;
  subtest 'content_array' => sub {
    plan tests => 3;
    for ( 1 .. 3 ) {
      is_deeply( [ Package::Stash::Data::String->content_array('IDontExist') ], [], 'Depth Compare' );
    }
  };

  subtest 'content' => sub {
    plan tests => 3;
    for ( 1 .. 3 ) {
      is( Package::Stash::Data::String->content('IDontExist'), '', 'String Compare' );
    }

  };

  }
