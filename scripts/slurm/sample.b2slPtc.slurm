#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.b2slPtc
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=sample.b2slPtc.o%j
#SBATCH --error=sample.b2slPtc.e%j

#b2slPtc
for i in {0..2}; do
    LC_ALL=C LANG=C join -t\; -a2 -o auto -e null \
        <(zcat data/sample.b2sl.s) \
        <(zcat data/sample.b2Ptc.${i}y) |
    gzip >data/sample.b2slPtc.${i}y;
    echo "finished file $i";
done;
