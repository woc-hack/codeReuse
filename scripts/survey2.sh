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

# initial sample
# can 0 -> 5000000
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
#b2ftAc -> 1356261
LC_ALL=C LANG=C join -t\; \
    <(zcat data/survey/second/can.b2f.s) \
    <(zcat data/survey/second/can.b2tAc.s | ~/lookup/lsort 50G -t\;) |
gzip >data/survey/second/can.b2ftAc.s;
# b2ft
zcat data/survey/second/can.b2ftAc.s |
cut -d\; -f1-3 |
awk -F\; '{if ($2!="") print}' \
>data/survey/second/can.b2ft.s;
# survey2.ipynb
# f -> f>10000 , t -> 10 bins
#b2ftAc.2 -> 1356243
LC_ALL=C LANG=C join -t\; \
    data/survey/second/can.b2ft.s \
    <(zcat data/survey/second/can.b2ftAc.s | cut -d\; -f1,4,5) |
gzip >data/survey/second/can.b2ftAc.2.s;
# can 1 -> 3257231
# 1$key;2$b;3$f;4$t;5$A;6$c;7$uP;8$nsu;9$ncmtu;10$d;11$dP;12$nsd;13$ncmtd
LC_ALL=C LANG=C join -t\; -2 4\
    <(zcat data/survey/second/can.b2ftAc.2.s) \
    <(zcat data/survey/second/can.0 |
        cut -d\; -f1,4,8,11,12,15,18,22 |
        ~/lookup/lsort 50G -t\; -k4,4) |
perl -e 'while(my $l=<STDIN>){$n=$n+1;print "$n;$l"}' |
gzip >data/survey/second/can.1.bs;
# delay, star, commit as categorical factor
zcat data/survey/second/can.1.bs |
cut -d\; -f1,8,9,10,12,13 >Rtmp;
# survey2.ipynb
# d -> "<1" "1< <3" ">3" , stars/commit -> b,m,s
# can 2 -> 3066342
# 1$key;2$b;3$f;4$t;5$A;6$c;7$uP;8$dP;9$d;10$s
LC_ALL=C LANG=C join -t\; \
    <(zcat data/survey/second/can.1.bs | 
        cut -d\; -f1-7,11 |
        ~/lookup/lsort 50G -t\; -k1,1) \
    <(~/lookup/lsort 50G -t\; -k1,1 <Rtmp) |
gzip >data/survey/second/can.2.ks;
# filtering user emails
# A2e -> 127691
zcat data/survey/second/can.2.ks | 
cut -d\; -f5 | 
~/lookup/lsort 50G -u | 
while read -r a; do
    echo "$a;$(echo "$a" | sed 's|.*<||;s|>.*||')"
done |
awk -F\; '{if ($2!="") print}' |
gzip >data/survey/second/can.A2e.s;
# github api
zcat data/survey/second/can.A2e.s | 
cut -d\; -f2 |
while read -r email; do
    ((c++));
    l=$((c%10+1));
    echo "$email;$(curl -s \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: token $(sed -n ${l}p ~/github_tokens)" \
        "https://api.github.com/search/users?q=${email}" |
        jq .total_count)"
done |
~/lookup/lsort 10G -t\; -k1,1 -u |
gzip >data/survey/second/can.e2v.s;
# A2ev -> 127690
LC_ALL=C LANG=C join -t\; -1 2 \
    <(zcat data/survey/second/can.A2e.s | ~/lookup/lsort 50G -t\; -k2,2) \
    <(zcat data/survey/second/can.e2v.s) |
awk -F\; '{print $2";"$1";"$3}' |
~/lookup/lsort 10G -t\; -k1,1 -u |
gzip >data/survey/second/can.A2ev.s;
# can 3 -> 654876
# 1$k;2$b;3$f;4$t;5$uA;6$uc;7$uP;8$dP;9$d;10$s;11$ue
LC_ALL=C LANG=C join -t\; -1 5 \
    <(zcat data/survey/second/can.2.ks |
        ~/lookup/lsort 10G -t\; -k5,5) \
    <(zcat data/survey/second/can.A2ev.s |
        awk -F\; '{if ($3==1) print}') |
awk -F\; '{print $2";"$3";"$4";"$5";"$1";"$6";"$7";"$8";"$9";"$10";"$11}' |
gzip >data/survey/second/can.3.As;
# reducing and stratifying sample 
zcat data/survey/second/can.3.As |
cut -d\; -f1,3,4,7,9,10,11 >Rtmp;
# survey2.ipynb
# can 4 -> 65260
LC_ALL=C LANG=C join -t\; \
    <(zcat data/survey/second/can.3.As |
        ~/lookup/lsort 10G -t\; -k1,1) \
    <(~/lookup/lsort <Rtmp) |
gzip >data/survey/second/can.4.ks;
