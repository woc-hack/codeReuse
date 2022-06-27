#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.times2
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=sample.times2.o%j
#SBATCH --error=sample.times2.e%j

ver=U;

zcat data/sample.b2tP.s | 
tail -n +339393419 |
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
gzip >data/sample.b2tP.times2 ;
echo "finished creating times";
