use strict;
use warnings;

use Test::More tests => 3;    # last test to print
use Test::Exception;

use FindBin;
use lib "${FindBin::Bin}/lib";

use Data;
use Package::Stash::Data::FileHandle;

sub lslurp {
  my $fh     = shift;
  my $length = 0;
  while (<$fh>) {
    $length += length($_);
  }
  return $length;
}

subtest 'has_fh' => sub {
  plan tests => 20;

  for ( 1 .. 10 ) {
    ok( Package::Stash::Data::FileHandle->has_fh('Data'),        'Data has the DATA filehandle' );
    ok( !Package::Stash::Data::FileHandle->has_fh('IDontExist'), 'NonExistentPackage has no DATA filehandle' );
  }
};

subtest 'get_fh nonfatal' => sub {
  plan tests => 10;

  for ( 1 .. 10 ) {
    lives_ok {
      Package::Stash::Data::FileHandle->get_fh('Data');
    }
    'get_fh nonfatal';
  }
};

subtest 'get_fh linecheck' => sub {
  plan tests => 10;

  for ( 1 .. 10 ) {
    is( lslurp( Package::Stash::Data::FileHandle->get_fh('Data') ), 13 + 1 + 1 + 21, 'Line length' );
  }
};

