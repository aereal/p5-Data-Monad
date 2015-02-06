package Data::Monad::Either;
use strict;
use warnings;
use parent qw/Data::Monad::Base::Monad/;
use Exporter qw/import/;

our @EXPORT = qw/left right/;

sub left {
    return bless [@_], __PACKAGE__ . '::Left';
}

sub right {
    return bless [@_], __PACKAGE__ . '::Right';
}

# from Data::Monad::Base::Monad

sub unit {
    my ($class, @v) = @_;
    return right(@v);
}

sub flat_map {
    my ($self, $f) = @_;
    return $self->is_left ? $self : $f->($self->value);
}

# instance methods

sub value {
    my ($self) = @_;
    return wantarray ? @$self : $self->[0];
}

package Data::Monad::Either::Left;
use parent -norequire, 'Data::Monad::Either';

sub is_left  { 1 }
sub is_right { 0 }

package Data::Monad::Either::Right;
use parent -norequire, 'Data::Monad::Either';

sub is_left  { 0 }
sub is_right { 1 }

1;
