#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.b2sl2
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --ntasks-per-node=6
#SBATCH --partition=campus
#SBATCH --output=sample.b2sl2.o%j
#SBATCH --error=sample.b2sl2.e%j

#b2sl
LC_ALL=C LANG=C join -t\; -a1 -o auto -e null \
    <(zcat data/sample.blobs.s) \
    <(zcat data/sample.b2sl.s) |
gzip >tmp;
mv tmp data/sample.b2sl.s;
echo "finished";
