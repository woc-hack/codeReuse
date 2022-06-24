#!/bin/bash
#SBATCH -A ACF-UTK0011 
#SBATCH -J notCopied2P
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=campus
#SBATCH --output=notCopied2P0.o%j
#SBATCH --error=notCopied2P0.e%j

ver=U;
#copied and not copied blobs
dir="/nfs/home/audris/work/c2fb/";
for i in {1..19}; do 
    LC_ALL=C LANG=C join -t\; -v1 \
        <(zcat ${dir}b2tPFull${ver}$i.s | cut -d\; -f1,3) \
        <(zcat data/b2tPFull${ver}$i.copied) |
    uniq |
    gzip >data/notCopiedb2PFull${ver}$i.s;
    echo "File $i finished!"
done;
