#!/usr/bin/bash

#small to big
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8<10 && $4==0 && $22>100 && $18>10) print}' \
    > ../data/survey/second/sTb.$i;
done;
#big to big
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8>100 && $4>10 && $22>100 && $18>10) print}' \
    > ../data/survey/second/bTb.$i;
done;
#big to small
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8>100 && $4>10 && $22<10 && $18==0) print}' \
    > ../data/survey/second/bTs.$i;
done;
#small to small
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8<10 && $4==0 && $22<10 && $18==0) print}' \
    > ../data/survey/second/sTs.$i;
done;
#random
for i in {0..1}; do
	shuf -n 20000000 <(zcat /da5_data/basemaps/gz/annote$i.gz) \
    > ../data/survey/second/rand.$i;
done;
#gzip
for set in sTb bTb bTs sTs rand; do
    for i in {0,1}; do
        gzip "data/survey/second/${set}.$i"
    done;
done

# initial sample -> 5000000
for set in sTb bTb bTs sTs rand; do
    for i in {0,1}; do
        shuf -n 500000 "data/survey/second/${set}.$i"
    done;
done |
gzip >data/survey/second/can.0;
# uniq blobs -> 1596510
zcat data/survey/second/can.0 | 
cut -d\; -f11 |
~/lookup/lsort 50G -u |
gzip >data/survey/second/can.blobs.s;
# b2f -> 1629961
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/survey/second/can.blobs.s) \
        <(zcat /da?_data/basemaps/gz/b2fFullU"$i".s)
done | 
sed 's|;.*\.|;|g' |
awk -F\; '{if (length($2) < 5) print}' |
~/lookup/lsort 50G -u |
gzip >data/survey/second/can.b2f.s;
# f>1 -> 106175
zcat data/survey/second/can.b2f.s |
cut -d\; -f1 |
uniq -d >tmp;
# b2f==1 -> 1366008
LC_ALL=C LANG=C join -t\; -v1 \
    <(zcat data/survey/second/can.b2f.s) \
    tmp |
gzip > b2f;
mv b2f data/survey/second/can.b2f.s;
rm tmp;
# b2tAc -> 1586187
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/survey/second/can.blobs.s) \
        <(zcat /da?_data/basemaps/gz/b2fAFullU"$i".s)
done |
gzip >data/survey/second/can.b2tAc.s;
# filtering user emails
zcat data/survey/second/can.b2tAc.s | 
cut -d\; -f1,3 |
while read -r line; do
    ((c++));
    l=$((c%10+1));
    b=$(echo "$line" | cut -d\; -f1);
    email=$(echo "$line" | cut -d\; -f2 | sed 's|.* <||;s|>.*||');
    echo "$b;$email;$(curl -s \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: token $(sed -n ${l}p ~/github_tokens)" \
        "https://api.github.com/search/users?q=${email}" |
        jq .total_count)"
done |
gzip >data/survey/second/can.b2e1.s;
#b2ftAc -> 1356261
LC_ALL=C LANG=C join -t\; \
    <(zcat data/survey/second/can.b2f.s) \
    <(zcat data/survey/second/can.b2tAc.s | ~/lookup/lsort 50G -t\;) |
gzip >data/survey/second/can.b2ftAc.s;
