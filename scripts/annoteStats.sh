#!/usr/bin/bash

#hist
##2$nmc;3$nblob;4$nsa;7$ncore;8$ncmt;9$na;13$cPr;14$cST;16$nmcb;17$nblobb;18$nsb;21$ncoreb;22$ncmtb;23$nab
for i in {2,3,4,7,8,9,13,14,16,17,18,21,22,23}; do
        for j in {0..31}; do
                zcat /da5_data/basemaps/gz/annote$j.gz |
                cut -d\; -f"$i" |
		~/lookup/lsort 10G -n |
		uniq -c |
		awk '{if (NF==1) print $1" -1"; else print }' \
		> data/annoteStats/split/$i.$j.hist;
        done;
done
##merging results
recJoin() {
	if [ $# -eq 1 ]; then
		join -1 1 -2 2 -a1 -a2 - <(cat "$1" | ~/lookup/lsort 10G -k2,2);
	else
		f=$1;
		shift;
		join -1 1 -2 2 -a1 -a2 - <(cat "$f" | ~/lookup/lsort 10G -k2,2) | recJoin "$@";
	fi;
};
for i in {2,3,4,7,8,9,13,14,16,17,18,21,22,23}; do
	join -1 2 -2 2 -a1 -a2 \
		<(cat data/annoteStats/split/$i.0.hist | ~/lookup/lsort 10G -k2,2) \
		<(cat data/annoteStats/split/$i.1.hist | ~/lookup/lsort 10G -k2,2) |
	recJoin $(for j in {2..31};do echo "data/annoteStats/split/$i.$j.hist";done) |
	awk '{sum=0;for(i=2; i<=NF; i++) {sum+=$i} print $1";"sum}' | 
	~/lookup/lsort 10G -t\; -k1,1 -n > data/annoteStats/$i.hist;
done

