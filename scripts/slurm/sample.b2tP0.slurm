#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.b2tP0
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=sample.b2tP0.o%j
#SBATCH --error=sample.b2tP0.e%j

ver=U;
#join with sample projects
for i in {0..127}; do 
    LC_ALL=C LANG=C join -t\; \
        <(cut -d\; -f1 <data/sample.s) \
        <(zcat data/P2notCopiedbFull${ver}$i.s);
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.P2notCopiedb.s;
echo "Finished notCopied join";
#geting all the sample blobs
for file in {P2fb,P2notCopiedb}; do
    zcat data/sample.${file}.s 
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.P2b.s;
zcat data/sample.P2b.s |
awk -F\; '{print $2";"$1}' |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.b2P.s;
zcat data/sample.b2P.s |
cut -d\; -f1 |
gzip >data/sample.blobs.s;
echo "Finished consolidating blobs";
#joining with b2tP
dir="/nfs/home/audris/work/c2fb/";
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/sample.blobs.s) \
        <(zcat ${dir}b2tPFull${ver}$i.s) \
    > data/sample.b2tP$i;
    echo "Finished b2tP join $i ";
done;
