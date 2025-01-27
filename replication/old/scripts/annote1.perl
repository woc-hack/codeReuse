use strict;
use warnings;

my %active;
my %stats;
my (%p2P, %top, %seen);
open A, "/data/play/forks/ManyMonthsActive0";
while (<A>){
  chop();
  my ($f, $na, $ncmt, $ncore, $nmc, $nblob, $ft, $lt, @rest) = split(/;/);
  $active{$f} = $nmc;
  if ($nmc>36){
    $top{ac36}{$f}++;
  }else{
    if ($nmc>11){
      $top{ac11}{$f}++;
    }else{
      $top{ac0}{$f}++;
    }
  }
  $stats{$f} = "$_";
}

my $map = "ght.P2w.cnt";
open A, "zcat $map|";
while (<A>){
  chop();
  my ($f, $ns) = split(/;/);
  $p2P{$f} = $ns;
  if ($ns>100){
    $top{100}{$f}++;
  }else{
    if ($ns>8){
      $top{8}{$f}++;
    }else{
      $top{0}{$f}++;
  }
  }
  $seen{$f}++;
}
for my $f (keys %stats){
  $top{0}{$f}++ if (!defined $seen{$f});
}
my (%cnt, %cnt1);
my %qs;
my ($n, $ma, $s, $ls, $eq0, $up, $down) = (0, 0, 0, 0, 0);
my $pa = "";
my @pp;
my %pb;
my ($cPr, $cST)  = (0, 0);
while(<STDIN>){
  chop();
  my @x=split(/;/);
  my $a = $x[0];
  my $b = $x[2];
  if ($pa ne "" && $pa ne $a){
    @pp = ();
    %pb = ();
    $cPr = 0;
    $cST = 0;
  }

  my $nsa = defined $p2P{$a} ? $p2P{$a} : 0;
  my $nsb = defined $p2P{$b} ? $p2P{$b} : 0;
  my $aca = defined $active{$a} ? $active{$a} : 0;
  my $acb = defined $active{$b} ? $active{$b} : 0;
  $x[3]=~s/^0+//;
  $x[1]=~s/^0+//;
  if (length($x[1])>=4 && length($x[3]) >= 4){
    my $v=($x[3]-$x[1])/3600/24/365.25;
    if ($v > 50){
      #print "@x" if $v > 50;
      next;
    }
    my $statea = $aca > 36 ? "a36" : ($aca>11 ? "a11" : "a0");
    my $stateb = $acb > 36 ? "a36" : ($acb >11 ? "a11" : "a0");
    my $stateas = $nsa > 100 ? "s100" : ($nsa > 8 ? "s8" : "s0");
    my $statebs = $nsb > 100 ? "s100" : ($nsb > 8 ? "s8" : "s0");
    my ($f, $na, $ncmt, $ncore, $nmc, $nblob,$ft, $lt, @rest) = split (/;/, $stats{$a}, -1);
    my ($fb, $nab, $ncmtb, $ncoreb, $nmcb, $nblobb, $ftb, $ltb, @restb) = split (/;/, $stats{$b}, -1);
    
    # calculate cumulative prior spread
    # print "$a;$na;$ncmt;$ncore;$nmc;$nblob;$nsa;$x[1];$x[4];delay;cumspred;propB
    #do this later $pb{$x[4]}{$b} = "$nab;$ncmtb;$ncoreb;$nmcb;$nblobb";
    print "$a;$nmc;$nblob;$nsa;$ft;$lt;$ncore;$ncmt;$na;$x[1];$x[4];$v;$cPr;$cST;$b;$nmcb;$nblobb;$nsb;$ftb;$ltb;$ncoreb;$ncmtb;$nab\n";
    $cPr++;
    $cST+=$nsb;
  }
  $pa = $a;
}
#x=read.table("/data/basemaps/gz/annote1",sep=";",header=F)
#names(x)=c("a","na","nb","ns","t","blob","del","cPr","cST","b","nba","nbb","nbs")
#x$choice=1
#x$alt = "yes"
#x$case = 1:dim(x)[1];
#y=x
#y$choice=0
#y$alt = "no"
#res=rbind(x,y)
#res = res[,-c(1,6,10)];
#MC <- dfidx(res, alt.levels = c("yes", "no"), idx ="case");
#library("Formula")
#f <- Formula(choice ~ cPr+cST +del| na  + nb + ns + nbs + nbb +nba)
#mf <- model.frame(MC, f)

