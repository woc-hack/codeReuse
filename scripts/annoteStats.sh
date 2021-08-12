#!/usr/bin/bash

#hist
##2$nmc;3$nblob;4$nsa;7$ncore;8$ncmt;9$na;13$cPr;14$cST;16$nmcb;17$nblobb;18$nsb;21$ncoreb;22$ncmtb;23$nab
for i in {2,3,4,7,8,9,13,14,16,17,18,21,22,23}; do
	for j in {0..31}; do
        	zcat /da5_data/basemaps/gz/annote$j.gz |
		cut -d\; -f"$i";
	done |
	sort -n | 
	uniq -c > data/annoteStats/$i.hist;
done
