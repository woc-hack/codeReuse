#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.b2sl
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=sample.b2sl.o%j
#SBATCH --error=sample.b2sl.e%j

#b2sl
ver=U;
dir="/nfs/home/audris/work/All.blobs/";
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
    <(zcat data/sample.blobs.s) \
    <(zcat ${dir}b2slfclFull${ver}$i.s | cut -d\; -f1-3) 
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.b2sl.s;
