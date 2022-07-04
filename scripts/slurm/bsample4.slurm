#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J bsample4
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=bsample4.o%j
#SBATCH --error=bsample4.e%j

ver=U;
s=14;

#b2sl
dir="/nfs/home/audris/work/All.blobs/";
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/bsample.blobs.s) \
        <(zcat ${dir}b2slfclFull${ver}$i.s | cut -d\; -f1-3) 
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/bsample.b2sl.s &&
echo "finished b2sl join";
LC_ALL=C LANG=C join -t\; -a1 -o auto -e null \
    <(zcat data/bsample.blobs.s) \
    <(zcat data/bsample.b2sl.s) |
gzip >tmp;
mv tmp data/bsample.b2sl.s &&
echo "finished b2sl";
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
