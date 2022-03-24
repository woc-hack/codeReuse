#!/usr/bin/bash

for i in {0..1}; do
    for j in {0..127}; do
        LC_ALL=C LANG=C join -t\; -a1 -1 1 -2 1 \
            data/blobs/blobs.$i \
            <(zcat /da?_data/basemaps/gz/b2fAFullU$j.s) \
        > data/blobs/b2fA/b2fA.$i.$j;
    done;
done;