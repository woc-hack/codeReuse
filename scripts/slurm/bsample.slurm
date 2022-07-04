#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J bsample
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=bsample.o%j
#SBATCH --error=bsample.e%j

ver=U;
s=14;

#blob sample
dir="/nfs/home/audris/work/c2fb/";
zcat ${dir}b2tPFull${ver}$s.s | 
cut  -d\; -f1 |
uniq |
gzip >data/bsample.blobs.s &&
echo "finished sample blobs";
#b2sl
dir="/nfs/home/audris/work/All.blobs/";
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -a1 -o auto -e null \
        <(zcat data/bsample.blobs.s) \
        <(zcat ${dir}b2slfclFull${ver}$i.s | cut -d\; -f1-3) 
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/bsample.b2sl.s &&
echo "finished b2sl";
#times
dir="/nfs/home/audris/work/c2fb/";
zcat ${dir}b2tPFull${ver}$s.s | 
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
gzip >data/bsample.b2Pt.times &&
echo "finished times";
#1-2 year
#b2Ptc
zcat data/bsample.b2Pt.times |
awk -F\; '{if (NF>3) {print $0";"1} else {print $0";"0}}' |
gzip >data/bsample.b2Ptc.0y &&
echo "finished b2Ptc 0";
i=1;
bound=1619874000;
for d in {31536000,63072000}; do
    zcat data/bsample.b2Pt.times |
    awk -F\; -v d="$d" '{l=$3+d;for (i=NF; i>=3; i=i-2) {if($i<=l) {b=i; break}}; 
        for (j=1; j<=b; ++j) {printf $j";";} print ""}' |
    awk -F\; '{if (NF>4) {print $0 1} else {print $0 0}}' |
    awk -F\; -v bound="$bound" '{if ($3<bound) print}' |
    gzip >data/bsample.b2Ptc.${i}y &&
    echo "finished b2Ptc $i";
    i=2;
    bound=1588338000;
done;
#b2slPtc
for i in {0..2}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/bsample.b2sl.s) \
        <(zcat data/bsample.b2Ptc.${i}y) |
    gzip >data/bsample.b2slPtc.${i}y &&
    echo "finished b2slPtc $i";
done;
#b2sltcd
for i in {0..2}; do
    zcat data/bsample.b2slPtc.${i}y |
    awk -F\; '{OFS=";"; print $1,$2,$3,$5,$NF,(NF-6)/2}' |
    gzip >data/bsample.b2sltcd.${i}y &&
    echo "finished b2sltcd $i";
done;
