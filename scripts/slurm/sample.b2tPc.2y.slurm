#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.b2tPc.2y
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --ntasks-per-node=32
#SBATCH --partition=campus
#SBATCH --output=sample.b2tPc.2y.o%j
#SBATCH --error=sample.b2tPc.2y.e%j

d=63072000;
zcat data/sample.b2tP.times |
    awk -F\; -v d="$d" '{l=$3+d;for (i=NF; i>=3; i=i-2) {if($i<=l) {b=i; break}}; 
        for (j=1; j<=b; ++j) {printf $j";";} print ""}' |
    awk -F\; '{if (NF>4) {print $0 1} else {print $0 0}}' |
    gzip >data/sample.b2tPc.2y;
echo "finished 2y";
