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
	recJoin "$(for j in {2..31};do echo "data/annoteStats/split/$i.$j.hist";done)" |
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

# general stats
for i in {1,11,15}; do
	echo "column $i unique count:";
	for j in {0..31}; do
			zcat "/da5_data/basemaps/gz/annote$j.gz" |
			cut -d\; -f"$i" |
			uniq |
			~/lookup/lsort 50G | 
			uniq;
	done |
	~/lookup/lsort 100G |
	uniq |
	wc -l;
done >> data/annoteStats/stat;

# random samples
for i in {0..31}; do
	shuf -n 20000000 <(zcat /da5_data/basemaps/gz/annote$i.gz);
done > ../data/annoteStats/rand0;
# blob sort
cat data/annoteStats/rand0 |
~/lookup/lsort 100G -t\; -k11,11 \
> data/annoteStats/rand0.bs;

# contingency table
# too slow
ns=(0 1 10 1000000);
ncmt=(0 10 100 1000000000);
d=(0 1 3 100);
cr=(0 1259539200 1417305600 1575072000 1700000000);
for i in {1..3}; do
	nsalb=${ns[$i]}
	nsaub=${ns[$i+1]}
	for j in {1..3}; do
		ncalb=${ncmt[$j]}
		ncaub=${ncmt[$j+1]}
		for k in {1..3}; do
			nsblb=${ns[$k]}
			nsbub=${ns[$k+1]}
			for l in {1..3}; do
				ncblb=${ncmt[$l]}
				ncbub=${ncmt[$l+1]}
				for m in {1..3}; do
					dlb=${d[$m];}
					dub=${d[$m+1];}
					for n in {1..4}; do
						crlb=${cr[$n]};
						crub=${cr[$n+1]};
						count=$(
							cat data/annoteStats/rand0 |
							awk -F\; -v nsalb=$nsalb -v nsaub=$nsaub -v ncalb=$ncalb -v ncaub=$ncaub \
								-v nsblb=$nsblb -v nsbub=$nsbub -v ncblb=$ncblb -v ncbub=$ncbub \
								-v dlb=$dlb -v dub=$dub -v crlb=$crlb -v crub=$crub \
								'{if ($4>=nsalb && $4<nsaub && $8>=ncalb && $8<ncaub && \
									$18>=nsblb && $18<nsbub && $22>=ncblb && $22<ncbub && \
									$12>=dlb && $12<dub && $10>=crlb && $10<crub) print 1}' |
							wc -l 
						)
						echo "upns$i;upcmt$j;downns$k;downncmt$l;d$m;cr$n;$count";
					done;
				done;
			done;
		done;
	done;
done;
# alternative
# adding big/med/sml variable
# #24$up;#25$down
cat data/annoteStats/rand0 |
awk -F\; '{if ($4>10 && $8>100) {print $0";1"} else if ($4==0 && $8<10) {print $0";3"} else {print $0";2"} }' |
awk -F\; '{if ($18>10 && $22>100) {print $0";1"} else if ($18==0 && $22<10) {print $0";3"} else {print $0";2"} }' \
> tmp;
rm data/annoteStats/rand0;
mv tmp data/annoteStats/rand0;
for i in {0,1}; do
	zcat "/da5_data/basemaps/gz/annote$i.gz" |
	awk -F\; '{if ($4>10 && $8>100) {print $0";1"} else if ($4==0 && $8<10) {print $0";3"} else {print $0";2"} }' |
	awk -F\; '{if ($18>10 && $22>100) {print $0";1"} else if ($18==0 && $22<10) {print $0";3"} else {print $0";2"} }' \
	> "data/annoteStats/copies.$i";
done;
mv data/annoteStats/rand0 data/annoteStats/copies.rand;
# building contingency table
for i in {0,1,rand}; do
	awk -F\; '{
		if ($12<1) {k=1} else if ($12<3) {k=2} else {k=3};
		if ($10<1259539200) {l=1} else if ($10<1417305600) {l=2} else if ($10<1575072000) {l=3} else {l=4};
		print "a"$24";b"$25";d"k";cr"l}' <"data/annoteStats/copies.$i" |
	~/lookup/lsort 100G |
	uniq -c |
	awk '{print $2";"$1}' \
	> "data/annoteStats/contingency.$i";
done;
# adding combinations with 0 count
for i in {1..3}; do
	for j in {1..3}; do
		for k in {1..3}; do
			for l in {1..4}; do
				echo "a$i;b$j;d$k;cr$l";
			done;
		done;
	done;
done | 
sort > tmp;
for f in {0,1,rand}; do
	join -a1 \
		tmp \
		<(sed 's|;\([0-9]*$\)| \1|' <"data/annoteStats/contingency.$f") |
	awk '{if (NF == 2) {print $1";"$2} else {print $1";"0}}' \
	> "tmp.$f";
	mv "tmp.$f" "data/annoteStats/contingency.$f";
done;
rm tmp;

# rand uniq blobs
cat data/annoteStats/rand0 |
cut -d\; -f1-4,7-9,11 |
~/lookup/lsort 100G -t\; -k8 |
uniq -c | 
awk '{print $2";"$1}' \
> data/blobs/blobs.rand;

# blob 2 file
for i in {0..127}; do
	LC_ALL=C LANG=C join -t\; -1 8 -2 1 \
		data/blobs/blobs.rand \
		<(zcat /da?_data/basemaps/gz/b2fFullU$i.s) \
	> data/blobs/b2f/b2f.rand.$i;
done;
for i in {0..127}; do
    cat data/blobs/b2f/b2f.rand.$i |
    sed 's|;.*\.|;|' |
    awk -F\; '{if (length($2) > 10) {print $1";"} else {print} }' |
    uniq > data/blobs/b2f/b2ext.rand.$i;
done;
for i in {0..127}; do
	cat data/blobs/b2f/b2ext.rand.$i |
	cut -d\; -f1 |
	uniq -c |
	awk '{if ($1 == 1) print $2}' > tmp.rand.$i;
	LC_ALL=C LANG=C join -t\; tmp.rand.$i data/blobs/b2f/b2ext.rand.$i;
done > data/blobs/b2ext.rand;
rm tmp.rand.*;
LC_ALL=C LANG=C join -t\; -1 8 -2 1 -a1 \
	data/blobs/blobs.rand \
	data/blobs/b2ext.rand |
awk -F\; '{if (NF == 9) {print $0";"} else {print}}' \
> tmp;
mv tmp data/blobs/blobs.rand;
