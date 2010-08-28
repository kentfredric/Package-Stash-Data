package Package::Stash::Data::String;

# ABSTRACT: Access Packages __DATA__ sections as arbitrary strings.
use strict;
use warnings;

use Package::Stash::Data::FileHandle;

=head1 SYNOPSIS

    my $string = Package::Stash::Data::String->content($package);
    my @strings = Package::Stash::Data::String->content_array($package);

=cut

my %datastash;

sub content_array {
  my ( $self, $package ) = @_;
  if ( exists { $datastash{$package} } ) {
    return @{ $datastash{$package} };
  }
  my @contentlines;
  unless ( Package::Stash::Data::FileHandle->has_fh($package) ) {
    return;
  }
  my $fh = Package::Stash::Data::FileHandle->get_fh($package);
  while (<$fh>) {
    push @contentlines, $fh;
  }
  $datastash{$package} = \@contentlines;
  return @contentlines;
}

sub content {
  my ( $self, $package ) = @_;
  return join( '', $self->content_array($package) );
}

1;

