#!/usr/bin/bash

# getting uniq blobs from annote files
# blob;Ncopy
for i in {0..31}; do
        zcat /da5_data/basemaps/gz/annote$i.gz |
        cut -d\; -f11 |
        ~/lookup/lsort 20G |
        uniq -c |
        awk '{print $2";"$1}' \
        > ../data/blobs/split/blobs.$i ;
done;
# merging results
recJoin() {
	if [ $# -eq 1 ]; then
		join -t\; -a1 -a2 - "$1";
	else
		f=$1;
		shift;
		join -t\; -a1 -a2 - "$f" | recJoin "$@";
	fi;
};
join -t\; -a1 -a2 ../data/blobs/split/blobs.0 ../data/blobs/split/blobs.1 |
recJoin $(for i in {2..31}; do echo "../data/blobs/split/blobs.$i";done) |
awk -F\; '{sum=0;for(i=2; i<=NF; i++) {sum+=$i} print $1";"sum}' |
~/lookup/splitSecCh.perl ../data/blobs/blobs. 8;

# bP
# P;nmc;nblob;nsa;ncore;ncmt;na;blob;Ncopy
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    cut -d\; -f1-4,7-9,11 |
    ~/lookup/lsort 10G |
    uniq -c |
    awk '{print $2";"$1}' \
    > ../data/blobs/uPb.$i;
done;

# getting first blobs for each project
# P;blob
for i in {0..1}; do
    cat ../data/projects/uP.$i |
    cut -d\; -f1 |
    ~/lookup/getValues -f P2fb \
    > ../data/blobs/uP2fb.$i;
done;
# adding project data to each line
# P;nmc;nblob;nsa;ncore;ncmt;na;blob
for i in {0..1}; do
    LC_ALL=C LANG=C join -t\; \
        <(cat ../data/projects/uP.$i | cut -d\; -f1-7) \
        ../data/blobs/uP2fb.$i \
    > ../data/blobs/uP2fb2.$i;
done;

# consolidating all blobs
# P;nmc;nblob;nsa;ncore;ncmt;na;blob;Ncopy
for i in {0..1}; do
    LC_ALL=C LANG=C join -a1 \
        <(cat ../data/blobs/uP2fb2.$i |
            ~/lookup/lsort 20G ) \
        <(cat ../data/blobs/uPb.$i | 
            sed 's|;\([0-9]*$\)| \1|' |
            ~/lookup/lsort 20G -k1,1) |
    awk '{if (NF == 2) {print $1";"$2} else {print $1";"0}}' \
    > ../data/blobs/uPab.$i;
done;
# random 
for i in {0..1}; do
    j=$((1-$i));
    shuf -n 20000000 <../data/blobs/uPab.$j \
    > ../data/blobs/uPab_test.$i;
done;


# augmentation
# blob;ext
for i in {0..1}; do
    cat ../data/blobs/uP2fb2.$i |
    cut -d\; -f8 |
    while read blob; do
        f=$(
            echo $blob |
            ~/lookup/getValues -f b2f |
            cut -d\; -f2 |
            awk -F. '{print $NF}' |
            ~/lookup/lsort |
            uniq -c |
            ~/lookup/lsort 10G -nr |
            head -1 |
            awk '{print $2}'
        );
        echo "$blob;$f";
    done > ../data/blobs/b2ext.$i;
done;

# getting first authors
# blob;time;Author;commit
for i in {0..1}; do
    cat ../data/blobs/uP2fb2.$i |
    cut -d\; -f8 |
    ~/lookup/getValues b2fA \
    > ../data/blobs/bfA.$i;
done;