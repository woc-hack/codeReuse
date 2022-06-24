#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J notCopied2P14
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=campus
#SBATCH --output=notCopied2P14.o%j
#SBATCH --error=notCopied2P14.e%j

ver=U;
#copied and not copied blobs
dir="/nfs/home/audris/work/c2fb/";
i=102;
LC_ALL=C LANG=C join -t\; -v1 \
    <(zcat ${dir}b2tPFull${ver}$i.s | cut -d\; -f1,3) \
    <(zcat data/b2tPFull${ver}$i.copied) |
uniq |
gzip >data/notCopiedb2PFull${ver}$i.s;
echo "File $i b2P finished!";
zcat data/notCopiedb2PFull${ver}$i.s |
awk -F\; '{print $2";"$1}' |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/P2notCopiedbFull${ver}$i.s;
echo "File $i P2b finished!";
