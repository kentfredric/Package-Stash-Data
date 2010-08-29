use strict;
use warnings;

package Package::Stash::Data::Sections;

# ABSTRACT: A Data::Section like object that can represent any package.
use Params::Classify qw( check_ref check_string check_regexp );
use Package::Stash::Data::FileHandle;

use namespace::autoclean;

sub _default_header_re {
  return qr/
    \A                # start
      _+\[            # __[
        \s*           # any whitespace
          ([^\]]+?)   # this is the actual name of the section
        \s*           # any whitespace
      \]_+            # ]__
      [\x0d\x0a]{1,2} # possible cariage return for windows files
    \z                # end
    /x;
}

sub _default_lazy {
  return 0;
}

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
  $object->{package}   = $params->{package};
  if ( exists $params->{header_re} ){
    $object->{header_re} = $params->{header_re};
  }
  if ( exists $params->{lazy} ){
    $object->{lazy}      = ( $params->{lazy} ? 1 : 0 );
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

sub stash {
  my ($self) = @_;
  if ( not $self->has_stash ) {
    $self->_populate_stash;
  }
  if ( not $self->has_stash ) {
    return;
  }
  return $self->{stash};
}

sub stash_section {
  my ( $self, $section ) = @_;
  return if not $self->has_stash_section($section);
  return $self->stash->{$section};
}

sub stash_section_names {
  my ($self) = @_;
  my $stash = $self->stash;
  return if not defined $stash;
  return keys %{$stash};
}

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

    last LINE if $line =~ /^__END__/;
    next LINE if !defined $current and $line =~ /^\s*$/;

    if ( not defined $current ) {
      require Carp;
      Carp::confess('bogus data section: text outside of named section');
    }

    # This is cargo cult from Data::Section.
    # I'm not sure what its for O_o.
    #
    $line =~ s/\A\\//;

    ${ $stash{$current} } .= $line;

  }
  $self->{stash} = \%stash;
  return;
}

sub header_re {
  if( not exists $_[0]->{header_re} ){
    $_[0]->{header_re} = $_[0]->_default_header_re ;
  }
  return $_[0]->{header_re};
}

sub package {
  return $_[0]->{package};
}

sub lazy {
  if ( not exists $_[0]->{lazy} ){
    $_[0]->{lazy} = $_[0]->_default_lazy;
  }
  return $_[0]->{lazy};
}

sub has_default_name {
  return exists $_[0]->{default_name};
}

sub default_name {
  if ( exists $_[0]->{default_name} ) {
    return $_[0]->{default_name};
  }
  return;
}

sub has_stash_section {
  my $stash = $_[0]->stash;
  return if not defined $stash;
  return if not exists $stash->{ $_[1] };
  return 1;
}

sub has_stash {
  return exists $_[0]->{stash};
}

1;

