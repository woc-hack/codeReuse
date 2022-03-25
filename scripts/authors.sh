#!/usr/bin/bash

# first authors
for i in {0..1}; do
    for j in {0..127}; do
        LC_ALL=C LANG=C join -t\; -1 1 -2 1 \
            data/blobs/blobs.$i \
            <(zcat /da?_data/basemaps/gz/b2fAFullU$j.s) \
        > data/blobs/b2fA/b2fA.$i.$j;
    done;
done;
for i in {0..1}; do
    for j in {0..127}; do
        cat data/blobs/b2fA/b2fA.$i.$j |
        cut -d\; -f1,13 | 
        ~/lookup/lsort 50G | 
        uniq;
    done > data/blobs/b2fA.$i;
done;

# uniq authors
for i in {0..1}; do
    cat data/blobs/b2fA.$i |
    cut -d\; -f2 |
    ~/lookup/lsort 50G |
    uniq > data/authors/authors.$i;
done;
