use strict;
use warnings;


my ($cPr, $cST)  = (0, 0);
my (%cnt, %cnt1);
while(<STDIN>){
  chop();
  #need to get time-varying stars/nmc
  my ($a,$nmc,$nblob,$nsa,$ft, $lt,$ncore,$ncmt,$na,$t1,$blob,$v,$cPr,$cST,$b,$nmcb,$nblobb,$nsb,$ftb, $ltb,$ncoreb,$ncmtb,$nab) = split(/;/);
  $nsa = defined $nsa ? $nsa : 0;
  $nsb = defined $nsb ? $nsb : 0;
  my $ns = $nsa <=> $nsb;
  my $nm = $nmc <=> $nmcb;
  $ft=~s/^0+//;
  $ftb=~s/^0+//;
  next if (length($ft) <  4 || length($ftb) < 4);
  my $nt = $ft <=> $ftb;
  my $nl = $t1 <=> $lt;
  my $aca = $nmc;
  my $acb = $nmcb;
  my $statea = $aca > 36 ? "a36" : ($aca>11 ? "a11" : "a0");
  my $stateb = $acb > 36 ? "a36" : ($acb >11 ? "a11" : "a0");
  my $stateas = $nsa > 100 ? "s100" : ($nsa > 8 ? "s8" : "s0");
  my $statebs = $nsb > 100 ? "s100" : ($nsb > 8 ? "s8" : "s0");
  $cnt1{"ns:$ns"}++; 
  $cnt1{"nm:$nm"}++; 
  $cnt1{"nt:$nt"}++;
  $cnt1{"nl:$nl"}++;
  $cnt1{"nt:$nt:ns:$ns"}++;
  $cnt1{"nt:$nt:nl:$nl"}++;
   
  $cnt{"a:$statea"}++; 
  $cnt{"a:$stateas"}++; 
  $cnt{"b:$stateb"}++; 
  $cnt{"b:$statebs"}++; 
  $cnt{"$statea-$stateb:$stateas-$statebs"}++;
}
for my $k (sort keys %cnt1){ 
  print "$k\;$cnt1{$k}\n";
}
for my $k (sort keys %cnt){ 
  print "$k\;$cnt{$k}\n";
}
