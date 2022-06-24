#!/bin/bash
#SBATCH -A ACF-UTK0011 
#SBATCH -J copiedb
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=campus
#SBATCH --output=copiedb1.o%j
#SBATCH --error=copiedb1.e%j

ver=U;
#copied and not copied blobs
dir="/nfs/home/audris/work/c2fb/";
for i in {1..127..4}; do 
    zcat ${dir}b2tPFull${ver}$i.s |
    cut -d\; -f1,3 |
    uniq |
    LC_ALL=C LANG=C sort -T. -u |
    cut -d\; -f1 |
    uniq -d |
    gzip >data/b2tPFull${ver}$i.copied;
    echo "File $i finished!";
done;
