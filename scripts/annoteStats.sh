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

#basic statistics
##number;count;mean;std;min;q1;median;q3;max
for i in {2,3,4,7,8,9,13,14,16,17,18,21,22,23}; do
	first=$(cat data/annoteStats/$i.hist | head -1 | cut -d\; -f1);
	n=1;
	if [ $first -eq -1 ]; then
		n=2;
	fi;
	res=$(cat data/annoteStats/$i.hist | sed -n "$n,\$p" |
		awk -F\; '{sum+=$2; sumpr+=$1*$2} END {print sum";"sumpr";"sumpr/sum}');
	count=$(echo $res | cut -d\; -f1);
	mean=$(echo $res | cut -d\; -f3);
	std=$(cat data/annoteStats/$i.hist | sed -n "$n,\$p" |
                awk -F\; -v mean=$mean -v sum=$count '{pr+=(($1-mean)**2)*$2} END {print sqrt(pr/sum)}');
	min=$(cat data/annoteStats/$i.hist | sed -n "$n p" | cut -d\; -f1);
	q1=$(cat data/annoteStats/$i.hist | sed -n "$n,\$p" |
		awk -F\; -v count=$count '{sum+=$2; if (sum > count/4) print $1}' | head -1);
	median=$(cat data/annoteStats/$i.hist | sed -n "$n,\$p" |
                awk -F\; -v count=$count '{sum+=$2; if (sum > count/2) print $1}' | head -1);
	q3=$(cat data/annoteStats/$i.hist | sed -n "$n,\$p" |
                awk -F\; -v count=$count '{sum+=$2; if (sum > count*3/4) print $1}' | head -1);
	max=$(cat data/annoteStats/$i.hist | tail -1 | cut -d\; -f1);
	echo "$i;$count;$mean;$std;$min;$q1;$median;$q3;$max";
done > data/annoteStats/stat;

# comparing total stats with two files
echo "" >> ../data/annoteStats/stat;
for j in {0..1}; do
	echo "annote $j:";
	for i in {2,3,4,7,8,9,13,14,16,17,18,21,22,23}; do
		path="../data/annoteStats/split/$i.$j.hist";
		first=$(cat $path | head -1 | awk '{print $2}');
		n=1;
		if [ $first -eq -1 ]; then
			n=2;
		fi;
		res=$(cat $path | sed -n "$n,\$p" |
			awk '{sum+=$1; sumpr+=$1*$2} END {print sum";"sumpr";"sumpr/sum}');
		count=$(echo $res | cut -d\; -f1);
		mean=$(echo $res | cut -d\; -f3);
		std=$(cat $path | sed -n "$n,\$p" |
			awk -v mean=$mean -v sum=$count '{pr+=(($2-mean)**2)*$1} END {print sqrt(pr/sum)}');
		min=$(cat $path | sed -n "$n p" | awk '{print $2}');
		q1=$(cat $path | sed -n "$n,\$p" |
			awk -v count=$count '{sum+=$1; if (sum > count/4) print $2}' | head -1);
		median=$(cat $path | sed -n "$n,\$p" |
			awk -v count=$count '{sum+=$1; if (sum > count/2) print $2}' | head -1);
		q3=$(cat $path | sed -n "$n,\$p" |
			awk -v count=$count '{sum+=$1; if (sum > count*3/4) print $2}' | head -1);
		max=$(cat $path | tail -1 | awk '{print $2}');
		echo "$i;$count;$mean;$std;$min;$q1;$median;$q3;$max";
	done;
	echo "";
done >> ../data/annoteStats/stat;