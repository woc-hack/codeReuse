#!/usr/bin/bash

#small to big
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8<10 && $4==0 && $22>100 && $18>10) print}' \
    > ../data/survey/second/sTb.$i;
done;
#big to big
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8>100 && $4>10 && $22>100 && $18>10) print}' \
    > ../data/survey/second/bTb.$i;
done;
#big to small
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8>100 && $4>10 && $22<10 && $18==0) print}' \
    > ../data/survey/second/bTs.$i;
done;
#small to small
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8<10 && $4==0 && $22<10 && $18==0) print}' \
    > ../data/survey/second/sTs.$i;
#random
for i in {0..1}; do
	shuf -n 20000000 <(zcat /da5_data/basemaps/gz/annote$i.gz) \
    > ../data/survey/second/rand.$i;
done;
