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