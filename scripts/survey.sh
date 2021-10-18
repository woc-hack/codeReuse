#!/usr/bin/bash

#small to big
for i in {0..31}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($2<10 && $4==0 && $16>10 && $18>10) print}'
done |
gzip > ../data/survey/sTb.gz;
#big to big
for i in {8..15}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($2>10 && $4>10 && $16>10 && $18>10) print}'
done |
gzip > ../data/survey/bTb.gz;
#big to small
for i in {16..23}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($2>10 && $4>10 && $16<10 && $18==0) print}'
done |
gzip > ../data/survey/bTs.gz;
#small to small
for i in {24..31}; do
zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($2<10 && $4==0 && $16<10 && $18==0) print}'
done |
gzip > ../data/survey/sTs.gz;

