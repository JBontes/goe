#! /usr/bin/perl

use warnings;
use strict;

my $vars;
sub clause { print "@_ 0\n" }
sub a_var() { ++$vars }
sub imp { clause (map (-$_, @_[0..$#_-1]), $_[-1]) } # $_0 & $_1 .. => $_-1
sub c_eq($$) { imp (@_); imp (map -$_, @_); }
sub one ($) { imp ( $_[0]) }
sub zero($) { imp (-$_[0]) }

sub cell {
	my $old = $_[4];
	my @nei = @_[0..3,5..8];

	my @d8 = 0..7;
	@nei==@d8 or die;

	# B3/S23
	my $new = a_var ();

	# <=1 -> D (8)
	for my $i (@d8) {
		imp (map (-$nei[$_], grep $_ != $i, @d8), -$new);
	}

	# 2 & D -> D (28)
	# 2 & A -> A (28)
	for my $i (@d8) {
	for my $j (@d8) { next if $j <= $i;
		my @f = map /$i|$j/ ? $nei[$_] : -$nei[$_], @d8;
		imp (@f, -$old, -$new);
		imp (@f,  $old,  $new);
	}}

	# 3 -> A (56)
	for my $i (@d8) {
	for my $j (@d8) { next if $j <= $i;
	for my $k (@d8) { next if $k <= $j;
		my @f = map /$i|$j|$k/ ? $nei[$_] : -$nei[$_], @d8;
		imp (@f, $new);
	}}}

	# >=4 -> D (70)
	for my $i (@d8) {
	for my $j (@d8) { next if $j <= $i;
	for my $k (@d8) { next if $k <= $j;
	for my $l (@d8) { next if $l <= $k;
		imp (@nei[$i,$j,$k,$l], -$new);
	}}}}

	return $new;
}

my $start;

sub var {
	my ($y, $x) = @_;

	$start->[$y][$x] ||= do {
		my $var = a_var ();
		print "c y=$y x=$x var=$var\n";
		$var;
	}
}

sub gen {
	my ($y, $x, $v) = @_;

	my $c = cell (
		var ($y-1, $x-1), var ($y-1, $x), var ($y-1, $x+1), 
		var ($y  , $x-1), var ($y  , $x), var ($y  , $x+1), 
		var ($y+1, $x-1), var ($y+1, $x), var ($y+1, $x+1), 
	);
	$v ? one ($c) : zero ($c);
}

my ($x, $y);
$y = 1;
while (<>) {
	$x = 1;
	for (/./g) {
		die "bad char $_" if !/[01.X?]/;
		gen ($y, $x, /1|X/) if !/\?/;
		$x++;
	}
	$y++;
}
