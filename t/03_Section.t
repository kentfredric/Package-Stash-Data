use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

use FindBin;
use lib "${FindBin::Bin}/lib";

use SectionData;
use Data::Dump qw( dump );
use Package::Stash::Data::Sections;

my $object = new_ok( 'Package::Stash::Data::Sections', [ { package => 'SectionData', lazy => 1 } ] );
is( ${ $object->stash_section('Section') },   "Hello.\n",     'Section 0 fetch works' );
is( ${ $object->stash_section('Section 2') }, "More data.\n", 'Section 1 fetch works' );

$object = new_ok( 'Package::Stash::Data::Sections', [ { package => 'SectionData' } ] );
is( ${ $object->stash_section('Section') },   "Hello.\n",     'Section 0 fetch works' );
is( ${ $object->stash_section('Section 2') }, "More data.\n", 'Section 1 fetch works' );

