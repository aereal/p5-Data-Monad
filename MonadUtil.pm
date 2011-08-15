package MonadUtil;
use AnyEvent;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw/m_unit m_join m_map m_bind/;

sub m_unit($) {
	my $v = shift;
	my $cv = AE::cv;
	$cv->send($v);

	return $cv;
}

sub m_join($) {
	my $cv2 = shift;

	my $cv_mixed = AE::cv;
	$cv2->cb(sub {
		my $cv = $_[0]->recv;
		$cv->cb(sub {
			my $v = $_[0]->recv;
			$cv_mixed->send($v);
		});
	});

	return $cv_mixed;
}

sub m_map($) {
	my $f = shift;
	return sub {
		my $cv = shift;
		my $cv_result = AE::cv;
		$cv->cb(sub {
			my $v = $_[0]->recv;
			$cv_result->send($f->($v));
		});

		return $cv_result;
	};
}

sub m_bind($$) {
	my ($cv, $f) = @_;
	my $cv2 = (m_map $f)->($cv);
	return m_join $cv2;
}

1;