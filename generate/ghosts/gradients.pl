#!/usr/bin/perl

use strict;

my $name   = 'tmp/grad';
my $ngrad  = $ARGV[0] || 15;
my $xexp   = 2.0/$ngrad;
my $fmt    = '%s%0'.length($ngrad).'d.pgm';
my $center = ($ngrad+1)/2;
my $xsize  = 16;
my $ysize  = 16;
my $vscale = 65535;

for (my $i = 1; $i <= $ngrad; $i++) {
    my $exp = exp(($i-$center)*$xexp);
    print "$i/$ngrad exponent = $exp\n";
    open(my $pgm, '>', sprintf($fmt, $name, $i)) or die;
    print $pgm "P2\n";
    printf $pgm "%d %d\n", $xsize, $ysize;
    printf $pgm "%d\n", $vscale;
    for (my $y = 0; $y < $ysize; $y++) {
	my $v = (($y+1)/($ysize+1))**$exp;
	my $vi = int($v*$vscale + 0.5);
	for (my $x = 0; $x < $xsize; $x++) {
	    print $pgm $vi, " ";
	}
	print $pgm "\n";
    }
    close($pgm);
}
