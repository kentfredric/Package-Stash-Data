use strict;
use warnings;

package Package::Stash::Data::FileHandle;
BEGIN {
  $Package::Stash::Data::FileHandle::VERSION = '0.01000017';
}

# ABSTRACT: A Very simple interface to the __DATA__  file handle.

use Package::Stash;

my %datastash;





sub has_fh {
  my ( $self, $package ) = @_;
  my $object = Package::Stash->new($package);
  return unless $object->has_package_symbol('DATA');
  my $fh = $object->get_package_symbol('DATA');
  return defined fileno *{$fh};
}


sub get_fh {
  my ( $self, $package ) = @_;
  my $object = Package::Stash->new($package);
  my $fh     = $object->get_package_symbol('DATA');
  if ( !exists $datastash{$package} ) {
    $datastash{$package} = tell $fh;
    return $fh;
  }
  seek $fh, $datastash{$package}, 0;
  return $fh;
}

1;


__END__
=pod

=head1 NAME

Package::Stash::Data::FileHandle - A Very simple interface to the __DATA__  file handle.

=head1 VERSION

version 0.01000017

=head1 SYNOPSIS

    package Foo;

    sub bar {
        for ( 1 .. 10 ){
            my $fh = Package::Stash::Data::FileHandle->get_fh(__PACKAGE__);
            while( <$fh> ){
                print $_;
            }
        }
    }

    __DATA__
    Foo

=head1 DESCRIPTION

This Package serves as a very I<very> simple interface to a packages __DATA__ section.

Its primary purposes is to make successive accesses viable without needing to scan the file manually for the __DATA__ marker.

It does this mostly by recording the current position of the file handle on the first call to get_fh, and then re-using that position on every successive call, which eliminates a bit of the logic for you.

=head1 METHODS

=head2 has_fh

Determine if C<$package> has a usable __DATA__ section that can be read.

    Package::Stash::Data::FileHandle->has_fh( $package );

=head2 get_fh

Get a readable file handle for the __DATA__ section of a given package.

    my $fh = Package::Stash::Data::FileHandle->get_fh( $package );
    while( <$fh> ){
        print $_;
    }

Returned $fh should hopefully be always rewound into the right location. Note its not always possible,
but this is only an 80% solution.

=head1 WARNING

At present, this module does you no favours if something else earlier has moved the file handle position past
the __DATA__ section, or rewound it to the start of the file. This is an understood caveat, but nothing else
seems to have a good way around this either.

Hopefully, if other people B<*do*> decide to go moving your file pointer, they'll use this module to do it so
you your code doesn't break.

Also, unfortunately, due to the way this works, if 2 people both call get_fh on the same package in
co-operative code things might be a bit weird, but this is pretty inescapable if you're working with the
file handle interface anyway, and its going to be by default a pretty evil thing to do.

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

