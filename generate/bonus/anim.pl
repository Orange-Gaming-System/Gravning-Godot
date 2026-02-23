#!/usr/bin/perl

use strict;
use integer;

my $width   = 15;
my $height  = 15;
my $spacing = 9;
my $pause1  = 2;
my $pause2  = 0;

my $tmp = 'tmp';

sub sys(@) {
    print STDERR join(' ', @_), "\n";
    return system(@_);
}

my @pngs;
sub mkpng($@) {
    my $cnt = shift(@_);
    push(@pngs, [$cnt, @_]);
}

mkdir($tmp, 0777);

my @img = (qw(blank)) x 5;

my @ltrs = qw(b o n u s);
my @series = qw(blank z2 z1 z0 z1 z2 edge x2 x1 x0);
my @imgs;

for (my $i = 0; $i < scalar @ltrs; $i++) {
    my $l = $ltrs[$i];

    for (my $j = 0; $j <= $#series; $j++) {
	$img[$i] = ($series[$j] =~ s/x/$l/r);
	mkpng(1, @img);
    }

    $pngs[-1]->[0] += $pause1;
}

$pngs[-1]->[0] += $pause2;

for (my $i = 0; $i < scalar @ltrs; $i++) {
    my $l = $ltrs[$i];

    for (my $j = $#series - 1; $j >= 0; $j--) {
	$img[$i] = ($series[$j] =~ s/x/$l/r);
	mkpng(1, @img);
    }

    $pngs[-1]->[0] += $pause1;
}
$pngs[-1]->[0] -= $pause1;


my $n = 0;
my @l;
my $y = 0;
my $xsz = 0;
foreach my $p (@pngs) {
    for (my $i = 0; $i < $p->[0]; $i++) {
	my $x = 0;
	for (my $j = 1; $j < scalar(@$p); $j++) {
	    my $im = $p->[$j];
	    push(@l, $im.'.png', '-geometry', "+$x+$y", '-composite');
	    $x += $width+$spacing;
	}
	$x -= $spacing;
	$xsz = $x if ($x > $xsz);
	$y += $height;
    }
    $n += $p->[0];
}

sys('magick', '-size', "${xsz}x${y}", 'xc:none', '-gravity', 'NorthWest',
    @l, qw(-alpha set bonus_anim.png));

print "Total frames: $n\n";
