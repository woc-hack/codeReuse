#!/usr/bin/bash

##1
p=$1;

zcat /da5_data/basemaps/gz/search.in | 
grep $p | 
sort -t\; -k7 -n | 
tail -10 | 
cut -d \; -f 1 |
while read line; do
	i=$p
	j=$line
	i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
	j=$(echo $j |~/lookup/getValues p2P| cut -d\; -f2)
	#echo $(echo $i |~/lookup/getValues P2p) $(echo $j |~/lookup/getValues P2p)
	echo $i |~/lookup/getValues -f P2b | cut -d\; -f2 |/home/audris/bin/lsort 10G > $i
	echo $j |~/lookup/getValues -f P2b | cut -d\; -f2 |/home/audris/bin/lsort 10G > $j
	firsti=$(cat $i | ~/lookup/getValues b2fa | cut -d\; -f4 | ~/lookup/getValues -f c2P | grep $i|wc -l)
	firstj=$(cat $j | ~/lookup/getValues b2fa | cut -d\; -f4 | ~/lookup/getValues -f c2P | grep $j|wc -l)
	#echo $i nblob=$(cat $i|wc -l) common with $j=$(join $i $j|wc -l) uniq=$(join -v1 $i $j|wc -l) first=$firsti 
	#echo $j nblob=$(cat $j|wc -l)  uniq=$(join -v2 $i $j|wc -l) first=$firstj

	join $i $j ; 
done;

##2
p=$1;

rm upstream.blobs 2>/dev/null;

echo $p | 
~/lookup/getValues p2P | 
cut -d \; -f 2 | 
~/lookup/getValues -f P2b |
sort -t \; -k 2 > $p.blobs

zcat /da5_data/basemaps/gz/search.in | 
grep $p | 
sort -t\; -k7 -n | 
tail -10 | 
cut -d \; -f 1 |
while read line; do
	j=$line;
	j=$(echo $j |~/lookup/getValues p2P| cut -d\; -f2);
	
	echo $j |~/lookup/getValues -f P2b | 
	cut -d\; -f2 |
	/home/audris/bin/lsort 10G | 
	~/lookup/getValues b2fa |
	sort -t \; -k 4 > blobs; 
	
	cat blobs | 
	cut -d\; -f4 | 
	~/lookup/getValues -f c2P | 
	grep $j | 
	sort -t \; -k 1 > origBlobs;

	join -t \; -1 4 -2 1 blobs origBlobs |
	uniq |
	sort -t \; -k 2 >> upstream.blobs;  
done;

join -t \; -1 2 -2 2 $p.blobs upstream.blobs;

rm $p.blobs blobs origBlobs upstream.blobs;

##3
p=$1;

i=$p;
i=$(echo $i |~/lookup/getValues p2P| cut -d\; -f2)
#get all blobs
echo $i |~/lookup/getValues -f P2b | cut -d\; -f2 |sort > $i
#get blobs originated
echo $i |~/lookup/getValues -f P2fb | cut -d\; -f2 |sort > $i.fb

rm $i.mostUsed 2>/dev/null;

zcat /da5_data/basemaps/gz/search.in | 
grep $p | 
sort -t\; -k7 -n | 
tail -5 | 
cut -d \; -f 1 |
while read line; do
	j=$line;
	j=$(echo $j |~/lookup/getValues p2P| cut -d\; -f2)
	#get all blobs
	echo $j |~/lookup/getValues -f P2b | cut -d\; -f2 |sort > $j
	#get blobs originated
	echo $j |~/lookup/getValues -f P2fb | cut -d\; -f2 |sort > $j.fb

	#list shared blobs created in $j and present in $i
	join $j.fb $i|~/lookup/getValues  b2f|cut -d\; -f1,2 >> $i.mostUsed
done;

cat $i.mostUsed |
cut -d\; -f2 | 
sed 's/.*\///' | 
grep '\.' | 
sed 's/.*\.//' | 
~/lookup/lsort 1G | 
uniq -c | 
sort -n | 
sed 's/ *//' |
tail;
