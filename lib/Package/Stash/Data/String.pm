use strict;
use warnings;

package Package::Stash::Data::String;
BEGIN {
  $Package::Stash::Data::String::VERSION = '0.01000017';
}

# ABSTRACT: Access Packages __DATA__ sections as arbitrary strings.
use Package::Stash::Data::FileHandle;


my %datastash;


sub content_array {
  my ( $self, $package ) = @_;
  if ( exists $datastash{$package} ) {
    return @{ $datastash{$package} };
  }
  my @contentlines;
  if ( not Package::Stash::Data::FileHandle->has_fh($package) ) {
    return;
  }
  my $fh = Package::Stash::Data::FileHandle->get_fh($package);
  while (<$fh>) {
    push @contentlines, $_;
  }
  $datastash{$package} = \@contentlines;
  return @contentlines;
}


sub content {
  my ( $self, $package ) = @_;
  return join q[], $self->content_array($package);
}

1;


__END__
=pod

=head1 NAME

Package::Stash::Data::String - Access Packages __DATA__ sections as arbitrary strings.

=head1 VERSION

version 0.01000017

=head1 SYNOPSIS

    my $string = Package::Stash::Data::String->content($package);
    my @strings = Package::Stash::Data::String->content_array($package);

=head1 METHODS

=head2 content_array

Returns an array of lines from __DATA__ split by \n.
Note: \n is still present on the end of lines.

    my @lines = Package::Stash::Data::String->content_array($package);

=head2 content

Returns a single scalar of the content of __DATA__

Mostly just a convenience call for join(@content_array($package))

    my $lines = Package::Stash::Data::String->content_array( $package )l

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

