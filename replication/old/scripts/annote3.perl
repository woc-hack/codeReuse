use strict;
use warnings;
use POSIX qw(mktime);
my $from = defined $ARGV[0] ? $ARGV[0] : 0;
my (%p2ts, %p2ns);
open A, "zcat starTime.gz|";
while (<A>){
  chop();
  my ($f, @x) = split(/;/);
  my @ts = ();
  my @ns = ();
  for my $i (@x){
    my ($t, $s) = split (/\=/, $i);
    push @ts, $t;
    push @ns, $s;
  }
  $p2ts{$f} = \@ts;
  $p2ns{$f} = \@ns;
}

sub ns {
  my ($f,$t) = @_;
  return 0 if !defined $p2ts{$f};
  my @ts = ();
  my @ns = ();
  if ("$p2ts{$f}" =~ /ARRAY/){
    @ts = @{$p2ts{$f}};
    @ns = @{$p2ns{$f}};
  }else{
    @ts = ($p2ts{$f});
    @ns = ($p2ns{$f});
  }
  return 0 if $t < $ts[0];
  return $ns[$#ns] if $t >= $ts[$#ts];
  for my $i (1..$#ts){
    return $ns[$i-1] if $t < $ts[$i];
  }
}
print STDERR "read map\n";
my $line = 0;
while (<STDIN>){
  chop();
  next if $line < $from;
  $line ++;
  my ($a,$nmc,$nblob,$nsa,$ft,$lt,$ncore,$ncmt,$na,$tcopied,$blob,$v,$cPr,$cST,$b,$nmcb,$nblobb,$nsb,$ftb,$ltb,$ncoreb,$ncmtb,$nab) = split (/;/);
  my $nsac = ns ($a, $tcopied);
  my $nsbc = ns ($b, $tcopied);
  my $nsab = ns ($a, $ftb);
  my $nsba = ns ($b, $ft);
  print "$nsac;$nsbc;$nsab;$nsba;$_\n";
}

