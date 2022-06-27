#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.times
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=sample.times.o%j
#SBATCH --error=sample.times.e%j

ver=U;

for i in {0..127}; do
    cat data/sample.b2tP$i
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.b2tP.s;
echo "finished merge and sort";
zcat data/sample.b2tP.s | 
perl -e '$pb="";
    while(<STDIN>){
        chop();
        ($bl,$t,$p)=split(/;/);
        if($bl ne $pb && $pb ne ""){
            print "$pb";
            for $pp (sort {$tmp{$a} <=> $tmp{$b} } keys %tmp){
                print ";$pp;$tmp{$pp}"
            }%tmp=();
            print "\n"
        };
        $pb=$bl;
        $tmp{$p}=$t if !defined $tmp{$p} || $tmp{$p} > $t;
    }' | 
gzip >data/sample.b2tP.times ;
echo "finished creating times";
