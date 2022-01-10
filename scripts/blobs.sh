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

# augmentation
# blob;Ncopy;Nline;ext
# too slow
for i in {0..1}; do
    cat ../data/blobs/blobs.$i |
    while read line; do
        n=$(
            echo $line | 
            cut -d\; -f1 | 
            ~/lookup/showCnt blob 2> /dev/null | 
            wc -l
        ); 
        f=$(
            echo $line |
            cut -d\; -f1 |
            ~/lookup/getValues -f b2f |
            awk -F. '{print $NF}' |
            ~/lookup/lsort |
            uniq -c |
            ~/lookup/lsort 10G -nr |
            head -1 |
            awk '{print $2}'
        );
        echo "$line;$n;$f";
    done > ../data/blobs/ablobs.$i;
done;

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
for i in {0..1}; do
    LC_ALL=C LANG=C join -t\; \
        <(cat ../data/projects/uP.$i | cut -d\; -f1-7) \
        ../data/blobs/uP2fb.$i \
    > ../data/blobs/uP2fb2.$i;
done;