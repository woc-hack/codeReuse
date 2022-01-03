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
# too slow, not feasible!
for i in {0..7}; do
    zcat ../data/blobs/blobs.$i.gz |
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

