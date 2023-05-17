#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.b2tPc.0y
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --ntasks-per-node=32
#SBATCH --partition=campus
#SBATCH --output=sample.b2tPc.0y.o%j
#SBATCH --error=sample.b2tPc.0y.e%j

zcat data/sample.b2tP.times |
awk -F\; '{if (NF>3) {print $0";"1} else {print $0";"0}}' |
gzip >data/sample.b2tPc.0y;
echo "finished 0y";
