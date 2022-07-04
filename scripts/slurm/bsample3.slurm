#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J bsample3
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=bsample3.o%j
#SBATCH --error=bsample3.e%j

ver=U;
s=14;

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
