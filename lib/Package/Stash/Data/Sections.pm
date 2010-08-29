use strict;
use warnings;

package Package::Stash::Data::Sections;

# ABSTRACT: A Data::Section like object that can represent any package.
use Params::Classify qw( check_ref check_string check_regexp );
use Package::Stash::Data::FileHandle;

use namespace::autoclean;

=p_method _default_header_re

Returns the default header parsing regex.

  $object->_defualt_header_re;

=cut

sub _default_header_re {
  return qr{
    \A                # start
      _+\[            # __[
        \s*           # any whitespace
          ([^\]]+?)   # this is the actual name of the section
        \s*           # any whitespace
      \]_+            # ]__
      [\x0d\x0a]{1,2} # possible cariage return for windows files
    \z                # end
    }x;
}

=p_method _default_lazy

Returns the default flag for lazyness (  False )

  $object->_default_lazy;

=cut

sub _default_lazy {
  return 0;
}

=method new

  Package::Stash::Data::Sections->new({   # Must be a HASHREF
    package => 'Some::Package'            # Mandatory.
    header_re => qr//x                    # Optional header parsing regex.
    default_name => 'Default'             # Optional: Enables out-of-section data
                                          #  to have an implicit section
    lazy => 1                             # Optional: Make content evaluation lazy.
  });

Create a new object containing the extracted sections.

Behaviourally this works a lot like L<Data::Section>, and in fact,
some of the code is stolen from that.

C<package> is a mandatory flag indicating where to look for the __DATA__

C<header_re> and C<default_name> are taken verbatim from L<Data::Section>

C<lazy> is an optional flag that controls when the data will be extracted, at C<< ->new() >> or when the
stash is first requested.

=cut

sub new {
  my ( $self, $params ) = @_;
  check_string($self);
  check_ref( $params, 'HASH' );
  check_string( $params->{package}, );
  if ( exists $params->{header_re} ) {
    check_regexp( $params->{header_re} );
  }
  if ( exists $params->{default_name} ) {
    check_string( $params->{default_name} );
  }
  if ( not exists $params->{lazy} ) {
    $params->{lazy} = 0;
  }
  my $object = {};
  $object->{package} = $params->{package};
  if ( exists $params->{header_re} ) {
    $object->{header_re} = $params->{header_re};
  }
  if ( exists $params->{lazy} ) {
    $object->{lazy} = ( $params->{lazy} ? 1 : 0 );
  }
  if ( exists $params->{default_name} ) {
    $object->{default_name} = $params->{default_name};
  }
  bless $object, $self;
  if ( not $object->lazy ) {
    $object->_populate_stash;
  }
  return $object;
}

=method stash

  my $stash = $object->stash();

Returns all the sections in a hashref.

Note that all strings are scalar refs, ie:

  my $stash = $object->stash();
  print ${ $stash->{'key' } };

If the stash is not populated, and can't be populated, it will return undef.

=cut

sub stash {
  my ($self) = @_;
  if ( not $self->has_stash ) {
    return;
  }
  return $self->{stash};
}

=method stash_section

  my $data = $object->stash_section('key');

Returns a scalar ref to the given section data in the objects stash.

  print ${ $object->stash_section('key' ) };

If the stash can't be populated, or the section does not exist, it will return undef.

=cut

sub stash_section {
  my ( $self, $section ) = @_;
  return if not $self->has_stash_section($section);
  return $self->stash->{$section};
}

=method stash_section_names

  my ( @names ) = $object->stash_section_names;

Returns all the names of the discovered sections.

If the stash can't be populated, it will return undef/empty list, depending on context.

=cut

sub stash_section_names {
  my ($self) = @_;
  my $stash = $self->stash;
  return if not defined $stash;
  return keys %{$stash};
}

=p_method _populate_stash

Internal method that populates the stash using the given parameters.

  $object->_populate_stash;

=cut

sub _populate_stash {
  my ($self) = @_;
  my %stash;
  if ( not Package::Stash::Data::FileHandle->has_fh( $self->package ) ) {
    return;
  }
  my $fh = Package::Stash::Data::FileHandle->get_fh( $self->package );

  my $current;

  if ( $self->has_default_name ) {
    $current = $self->default_name;
    $stash{$current} = \( my $blank = q{} );
  }
LINE: while ( my $line = <$fh> ) {
    if ( $line =~ $self->header_re ) {
      $current = $1;
      $stash{$current} = \( my $blank = q{} );
      next LINE;
    }

    last LINE if $line =~ qr{
      ^            # Start of line
      __END__      # Document END matcher
    }x;
    next LINE if !defined $current and $line =~ qr{
      ^
      \s*   # Any empty lines before the first section get ignored.
      $
    }x;

    if ( not defined $current ) {
      require Carp;
      Carp::confess('bogus data section: text outside of named section');
    }

    # This is cargo cult from Data::Section.
    # I'm not sure what its for O_o.
    #
    $line =~ s{
        \A      # String start
        \\      # Literal slash
    }{}x;

    ${ $stash{$current} } .= $line;

  }
  $self->{stash} = \%stash;
  return;
}

=method header_re

  $object->header_re;

Returns the regular expression used for header parsing.

=cut

sub header_re {
  if ( not exists $_[0]->{header_re} ) {
    $_[0]->{header_re} = $_[0]->_default_header_re;
  }
  return $_[0]->{header_re};
}

=method packge

  $object->package;

Returns the package this data is for.

=cut

sub package {
  return $_[0]->{package};
}

=method lazy

  $object->lazy;

Returns the lazy flag for this package.

=cut

sub lazy {
  if ( not exists $_[0]->{lazy} ) {
    $_[0]->{lazy} = $_[0]->_default_lazy;
  }
  return $_[0]->{lazy};
}

=method has_default_name

  $object->has_default_name

Returns whether or not the user specified 'default_name' at construction time.

=cut

sub has_default_name {
  return exists $_[0]->{default_name};
}

=method default_name

  $object->default_name

Returns the user specified 'default_name', or undef if it was not specified.

=cut

sub default_name {
  if ( $_[0]->has_default_name ) {
    return $_[0]->{default_name};
  }
  return;
}

=method has_stash_section

  $object->has_stash_section('Section Name');

returns a false value if the stash cannot be populated, or the stash section named didn't exist.

=cut

sub has_stash_section {
  my $stash = $_[0]->stash;
  return if not defined $stash;
  return if not exists $stash->{ $_[1] };
  return 1;
}

=method has_stash

  $object->has_stash;

Returns a false value if the stash cannot be populated.

=cut

sub has_stash {
  my ($self) = @_;
  if ( not $self->stash_populated ) {
    $self->_populate_stash;
  }
  if ( not $self->stash_populated ) {
    return;
  }
  return 1;
}

=method stash_populated

  $object->stash_populated

Returns whether or not the stash has been populated yet.

=cut

sub stash_populated {
  return exists $_[0]->{stash};
}

1;

