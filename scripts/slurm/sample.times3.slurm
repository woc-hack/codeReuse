#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.times3
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=campus
#SBATCH --output=sample.times3.o%j
#SBATCH --error=sample.times3.e%j


zcat sample.b2tP.times | 
head -123322872 >tmp;
zcat sample.b2tP.times2 >>tmp;
echo 'fffffff61d9d3aedbedbffea5adec67768d9143a;laerciosimoes_facebook-hacker-cup-2018;1531164455' \
>>tmp;
gzip <tmp >data/sample.b2tP.times;
echo "finished consolidating";
echo "times count: ";
zcat data/sample.b2tP.times |
wc -l;
echo "blob count check: ";
zcat data/sample.blobs.s |
wc -l;
echo "last and first: ";
zcat data/sample.b2tP.times |
head -123322873 |
tail -2;
echo "tail: ";
zcat data/sample.b2tP.times |
tail -5;
