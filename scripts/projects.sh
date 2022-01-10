#!/usr/bin/bash

# getting uniq projects from annote files
# project;Ncopy
for i in {0..1}; do
        zcat /da5_data/basemaps/gz/annote$i.gz |
        cut -d\; -f1-4,7-9 |
        ~/lookup/lsort 20G |
        uniq -c |
        awk '{print $2";"$1}' \
        > ../data/projects/uP.$i;
        zcat /da5_data/basemaps/gz/annote$i.gz |
        cut -d\; -f15-18,21-23 |
        ~/lookup/lsort 20G |
        uniq -c |
        awk '{print $2";"$1}' \
        > ../data/projects/dP.$i;
done;
