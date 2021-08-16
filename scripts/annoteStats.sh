#!/usr/bin/bash

#hist
##2$nmc;3$nblob;4$nsa;7$ncore;8$ncmt;9$na;13$cPr;14$cST;16$nmcb;17$nblobb;18$nsb;21$ncoreb;22$ncmtb;23$nab
###v1 - normal sort
for i in {2,3,4,7,8,9,13,14,16,17,18,21,22,23}; do
	for j in {0..31}; do
        	zcat /da5_data/basemaps/gz/annote$j.gz |
		cut -d\; -f"$i";
	done |
	sort -n | 
	uniq -c > data/annoteStats/$i.hist;
done
###v2 - using lsort
for i in {2,3,4,7,8,9,13,14,16,17,18,21,22,23}; do
        for j in {0..31}; do
                zcat /da5_data/basemaps/gz/annote$j.gz |
                cut -d\; -f"$i" |
		~/lookup/lsort 10G -n |
		uniq -c > data/annoteStats/$i.$j.hist;
        done;
done
###merging results
recJoin() {
	if [ $# -eq 1 ]; then
		join -1 1 -2 2 -a1 -a2 - <(cat "$1" | sort -k2,2);
	else
		f=$1;
		shift;
		join -1 1 -2 2 -a1 -a2 - <(cat "$f" | sort -k2,2) | recJoin "$@";
	fi;
};
for i in {2,3,4,7,8,9,13,14,16,17,18,21,22,23}; do
	join -1 2 -2 2 -a1 -a2 \
		<(cat data/annoteStats/$i.0.hist | sort -k2,2) \
		<(cat data/annoteStats/$i.1.hist | sort -k2,2) |
	recJoin $(for j in {2..31};do echo "data/annoteStats/$i.$j.hist";done) \
	> $i.hist
done

