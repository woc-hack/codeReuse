#!/usr/bin/bash

#survey 1
#small to big
for i in {0..31}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8<10 && $4==0 && $22>10 && $18>10) print}'
done |
gzip > ../data/survey/sTb.gz;
#big to big
for i in {8..15}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($8>10 && $4>10 && $22>10 && $18>10) print}'
done |
gzip > ../data/survey/bTb.gz;
#big to small
zcat /da5_data/basemaps/gz/annote16.gz |
awk -F\; '{if ($8>10 && $4>10 && $22<10 && $18==0) print}' |
gzip > ../data/survey/bTs.gz;
#small to small
zcat /da5_data/basemaps/gz/annote24.gz |
awk -F\; '{if ($8<10 && $4==0 && $22<10 && $18==0) print}' |
gzip > ../data/survey/sTs.gz;
#random
zcat /da5_data/basemaps/gz/annote17.gz | 
head -60000000 |
gzip >../data/survey/rand.gz;

#initial survey table
#1$upstream;2$nm;3$nblob;4$ns;5$ft;6$lt;7$ncore;8$ncmt;9$na;
#10$blobtime;11$blob;12$delay;13$cPr;14$cST;
#15$downstream;16$nm;17$nblob;18$ns;19$ft;20$lt;21$ncore;22$ncmt;23$na
#24$type;25$u2dCount;26$fCount
for set in sTb bTb bTs sTs rand; do
    #getting first 1 million entries
    zcat ../data/survey/$set.gz |
    head -1000000 > ../data/survey/initial/$set;
    #upstream-downstream combination counts
    cat ../data/survey/initial/$set |
    cut -d\; -f1,15 | 
    ~/lookup/lsort 10G |
    uniq -c |
    ~/lookup/lsort 10G -nr -k1,1 > ../data/survey/initial/$set.counts;
    #upstream counts
    cat ../data/survey/initial/$set |
    cut -d\; -f1 |
    ~/lookup/lsort 10G |
    uniq -c | 
    ~/lookup/lsort 10G -nr -k1,1 > ../data/survey/initial/$set.fcounts;
    #accumulation
    cat ../data/survey/initial/$set |
    while read line; do
        type=$(echo $line | 
            cut -d\; -f11 |
            ~/lookup/getValues -f b2f |
            sed 's|.*\.||g' |
            ~/lookup/lsort |
            uniq -c |
            ~/lookup/lsort 10G -nr |
            head -1 |
            sed 's| *||' |
            cut -d' ' -f2);
        ud=$(echo $line | cut -d\; -f1,15);
        count=$(cat ../data/survey/initial/$set.counts |
            grep "$ud" |
            sed 's| *||' | 
            cut -d' ' -f1);
        u=$(echo "$ud" | cut -d\; -f1);
        fcount=$(cat ../data/survey/initial/$set.fcounts |
            grep "$u" |
            sed 's| *||' | 
            cut -d' ' -f1);
        echo "$line;$type;$count;$fcount";
    done > ../data/survey/initial/$set.2 ;
done;

#candidates
rm ../data/survey/initial/candidates 2>/dev/null;
for set in sTb bTb bTs sTs rand; do
    cat ../data/survey/initial/$set.counts |
    awk '{i+=1; if (i%100 == 1) print}' |
    sed 's| *||' |
    cut -d' ' -f2 |
    while read line; do
        u=$(echo $line | cut -d\; -f1);
        d=$(echo $line | cut -d\; -f2);
        type=$(cat ../data/survey/initial/$set.2 |
            grep "$u" |
            grep "$d" |
            cut -d\; -f24 |
            ~/lookup/lsort |
            uniq -c |
            ~/lookup/lsort 10G -nr |
            head -1 |
            sed 's| *||' |
            cut -d' ' -f2);
        cat ../data/survey/initial/$set.2 |
        grep "$u" |
        grep "$d" |
        awk -F\; -v type="$type" '{if (length($24) < 10 && $24 == type) print}' |
        head -1;
    done > ../data/survey/initial/$set.candidates;
    c=$(cat ../data/survey/initial/$set.candidates | wc -l);
    cat ../data/survey/initial/$set.candidates |
    ~/lookup/lsort 10G -t\; -k24,24 |
    awk -F\; -v c=$(($c/120+1)) '{i+=1; if(i%c == 0) print}' \
    >> ../data/survey/initial/candidates;
done;
#augmentation
cat ../data/survey/initial/candidates |
cut -d\; -f1,11,15 |
awk -F\; '{print $1";"$2"\n"$3";"$2}' |
~/lookup/lsort |
uniq |
while read line; do
    P=$(echo $line | cut -d\; -f1);
    b=$(echo $line | cut -d\; -f2);
    cdat=$(echo $b |
        ~/lookup/getValues -f b2c |
        cut -d\; -f2 |
        ~/lookup/getValues -f c2P |
        grep "$P" |
        cut -d\; -f1 |
        ~/lookup/getValues c2dat |
        ~/lookup/lsort 20G -t\; -k2,2 -n |
        head -1 |
        cut -d\; -f1,2,4,5);
    c=$(echo $cdat | cut -d\; -f1);
    t=$(echo $cdat | cut -d\; -f2);
    date=$(date -d @$t | awk '{print $2" "$3" "$6}');
    A=$(echo $cdat |
        cut -d\; -f3 |
        ~/lookup/getValues -f a2A |
        cut -d\; -f2);
    f=$(echo $c | 
        ~/lookup/cmputeDiff3.perl 2>/dev/null | #works only on da5
        grep $b |
        head -1 |
        cut -d\; -f2);
    echo "$P;$b;$c;$date;$A;$f";
done > ../data/survey/initial/candidates.pb;
#27$uc;28$udate;29$uA;30$uf
#31$dc;32$ddate;33$dA;34$df
cat ../data/survey/initial/candidates | 
while read line; do
    ub=$(echo $line | cut -d\; -f1,11);
    pbu=$(cat ../data/survey/initial/candidates.pb | 
        grep "$ub" |
        cut -d\; -f3-6);
    db=$(echo $line | awk -F\; '{print $15";"$11}');
    pbd=$(cat ../data/survey/initial/candidates.pb | 
        grep "$db" |
        cut -d\; -f3-6);
    echo "$line;$pbu;$pbd";
done > ../data/survey/initial/candidates.aug;

#final table
#cleansing
cat ../data/survey/initial/candidates.aug | 
awk -F\; '{if (NF==34) print}' |
while read line; do
    va=$(echo $line | 
        cut -d\; -f29,33 |
        sed 's|;|\n|' |
        egrep '<[A-Za-z0-9._%+-]{1,}@[A-Za-z0-9.-]{1,}\.[A-Za-z]{2,}>' |
        wc -l);
    if [[ $va -ne 2 ]]; then
        continue;
    fi;
    echo $line;
done > ../data/survey/initial/candidates.final;

#upstream table
echo "name,email,blob,upstream_url,udate,ucommit,ufile" \
> ../data/survey/initial/candidates_up.csv;
cat ../data/survey/initial/candidates.final |
while read line; do
    name=$(echo $line |
        cut -d\; -f29 |
        sed 's| <[^<>]*>||' |
        sed 's|,|-|g' );
    email=$(echo $line |
        cut -d\; -f29 |
        sed 's|.* <\([^<>]*\)>|\1|' |
        sed 's|,|-|g' );
    blob=$(echo $line | cut -d\; -f11);
    up_url=$(echo $line |
        cut -d\; -f1 |
        sed 's|_|/|;s|^|https://github.com/|');
    udate=$(echo $line | cut -d\; -f28);
    ucommit=$(echo $line | cut -d\; -f27);
    ufile=$(echo $line | 
        cut -d\; -f30 |
        sed 's|,|-|g' );
    echo "$name,$email,$blob,$up_url,$udate,$ucommit,$ufile"
done >> ../data/survey/initial/candidates_up.csv;
#downstream table
echo "name,email,blob,upstream_url,udate,ucommit,downstream_url,ddate,dcommit,dfile" \
> ../data/survey/initial/candidates_down.csv;
cat ../data/survey/initial/candidates.final |
while read line; do
    name=$(echo $line |
        cut -d\; -f33 |
        sed 's| <[^<>]*>||' |
        sed 's|,|-|g' );
    email=$(echo $line |
        cut -d\; -f33 |
        sed 's|.* <\([^<>]*\)>|\1|' |
        sed 's|,|-|g' );
    blob=$(echo $line | cut -d\; -f11);
    up_url=$(echo $line |
        cut -d\; -f1 |
        sed 's|_|/|;s|^|https://github.com/|');
    udate=$(echo $line | cut -d\; -f28);
    ucommit=$(echo $line | cut -d\; -f27);
    down_url=$(echo $line |
        cut -d\; -f15 |
        sed 's|_|/|;s|^|https://github.com/|');
    ddate=$(echo $line | cut -d\; -f32);
    dcommit=$(echo $line | cut -d\; -f31);
    dfile=$(echo $line | 
        cut -d\; -f34 |
        sed 's|,|-|g' );
    echo "$name,$email,$blob,$up_url,$udate,$ucommit,$down_url,$ddate,$dcommit,$dfile"
done >> ../data/survey/initial/candidates_down.csv;

#survey 2

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
awk -F\; '{if ($2!="") print}' |
gzip >data/survey/second/can.b2ft.s;
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
# adding time and removing stratify vars
# 1$b;2$t;3$uA;4$uc;5$uP;6$dP;7$ue
LC_ALL=C LANG=C join -t\; \
    <(zcat data/survey/second/can.b2ftAc.s | 
        cut -d\; -f1,3 |
        ~/lookup/lsort 10G -t\; -k1,1 -u) \
    <(zcat data/survey/second/can.4.ks |
        cut -d\; -f2,5,6,7,8,11 |
        ~/lookup/lsort 10G -t\; -k1,1 -u) |
gzip >data/survey/second/can.5.bs;
    
# upstream table
zcat data/survey/second/can.5.bs |
perl -e 'while(my $l=<STDIN>){$n=$n+1;print "$n;$l"}' >tmp;
cut -d\; -f1,8 <tmp >Rtmp;
# survey2.ipynb
echo "name,email,blob,upstream_url,udate,ucommit,ufile" \
>data/survey/second/can_up.csv;
LC_ALL=C LANG=C join -t\; \
    <(~/lookup/lsort 10G -t\; -k1,1 <tmp) \
    <(~/lookup/lsort <Rtmp) |
cut -d\; -f2-6,8 |
while read -r line; do
    name=$(echo "$line" |
        cut -d\; -f3 |
        sed 's|<[^<>]*>$||;s|,|-|g');
    email=$(echo "$line" | cut -d\; -f6);
    blob=$(echo "$line" | cut -d\; -f1);
    up_url=$(echo "$line" |
        cut -d\; -f5 |
        sed 's|_|/|;s|^|https://github.com/|');
    t=$(echo "$line" | cut -d\; -f2);
    udate=$(date -d @"$t" | awk '{print $2" "$3" "$6}');
    ucommit=$(echo "$line" | cut -d\; -f4);
    ufile=$(echo "$ucommit" | 
        ~/lookup/cmputeDiff3.perl 2>/dev/null |
        grep "$blob" |
        head -1 |
        cut -d\; -f2 |
        sed 's|,|-|g');
    echo "$name,$email,$blob,$up_url,$udate,$ucommit,$ufile"
done >> data/survey/second/can_up.csv;
shuf -n 2900 data/survey/second/can_up.csv >tmp;
mv tmp data/survey/second/can_up.csv;

# downstream commit/author
# k;dc;dt;dA
zcat data/survey/second/can.4.ks |
cut -d\; -f1,2,8 |
while read -r l; do
    k=$(echo "$l" | cut -d\; -f1);
    b=$(echo "$l" | cut -d\; -f2);
    p=$(echo "$l" | cut -d\; -f3);
    echo "$k;$(echo "$b" |
        ~/lookup/getValues -f b2c |
        cut -d\; -f2 |
        ~/lookup/getValues c2P |
        grep ";$p$" |
        cut -d\; -f1 |
        ~/lookup/getValues c2dat |
        sort -t\; -nk2,2 | 
        head -1 |
        cut -d\; -f1,2,4)";
done |
gzip >data/survey/second/can.4.downData;
# d.A2e -> 48529
zcat data/survey/second/can.4.downData |
cut -d\; -f4 |
~/lookup/lsort 50G -u | 
while read -r a; do
    echo "$a;$(echo "$a" | sed 's|.*<||;s|>$||')"
done |
awk -F\; '{if ($2!="") print}' |
gzip >data/survey/second/can.d.A2e.s;
# github api
zcat data/survey/second/can.d.A2e.s | 
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
gzip >data/survey/second/can.d.e2v.s;
# dA2ev -> 127690
LC_ALL=C LANG=C join -t\; -1 2 \
    <(zcat data/survey/second/can.d.A2e.s | ~/lookup/lsort 50G -t\; -k2,2) \
    <(zcat data/survey/second/can.d.e2v.s) |
awk -F\; '{print $2";"$1";"$3}' |
~/lookup/lsort 10G -t\; -k1,1 -u |
gzip >data/survey/second/can.d.A2ev.s;
# joining with down data
LC_ALL=C LANG=C join -t\; -1 4 \
    <(zcat data/survey/second/can.4.downData |
        ~/lookup/lsort 10G -t\; -k4,4) \
    <(zcat data/survey/second/can.d.A2ev.s |
        awk -F\; '{if ($3==1) print $1";"$2}') |
gzip >data/survey/second/can.d.A2kcte.s;
# joining with can 4
# 1$k;2$b;3$uc;4$uP;5$dP;6$dA;7$dc;8$dt;9$de
LC_ALL=C LANG=C join -t\; -2 2 \
    <(zcat data/survey/second/can.4.ks |
        cut -d\; -f1,2,6,7,8) \
    <(zcat data/survey/second/can.d.A2kcte.s |
        ~/lookup/lsort 10G -t\; -k2,2 -u) |
gzip >data/survey/second/can.d.5.ks;
zcat data/survey/second/can.d.5.ks |
cut -d\; -f1,9 >Rtmp;
# survey2.ipynb
# getting uc time
LC_ALL=C LANG=C join -t\; -1 2 -2 2\
    <(zcat data/survey/second/can.b2ftAc.s | 
        cut -d\; -f3,5 |
        ~/lookup/lsort 10G -t\; -k2,2 -u) \
    <(zcat data/survey/second/can.d.5.ks |
        cut -d\; -f1,3 |
        ~/lookup/lsort 10G -t\; -k2,2 -u) |
awk -F\; '{print $3";"$2}' >tmp;
# 1$k;2$b;3$uc;4$uP;5$dP;6$dA;7$dc;8$dt;9$de;10$ut
LC_ALL=C LANG=C join -t\; \
    <(zcat data/survey/second/can.d.5.ks) \
    <(~/lookup/lsort 10G -t\; -k1,1 -u <tmp) |
gzip >data/survey/second/can.d.6.ks;
# final tavle
echo "name,email,blob,upstream_url,udate,ucommit,downstream_url,ddate,dcommit,dfile" \
>data/survey/second/can_down.csv;
LC_ALL=C LANG=C join -t\; \
    <(zcat data/survey/second/can.d.6.ks) \
    <(~/lookup/lsort <Rtmp) |
while read -r line; do
    name=$(echo "$line" |
        cut -d\; -f6 |
        sed 's|<[^<>]*>$||;s|,|-|g');
    email=$(echo "$line" | cut -d\; -f9);
    blob=$(echo "$line" | cut -d\; -f2);
    up_url=$(echo "$line" |
        cut -d\; -f4 |
        sed 's|_|/|;s|^|https://github.com/|');
    ut=$(echo "$line" | cut -d\; -f10);
    udate=$(date -d @"$ut" | awk '{print $2" "$3" "$6}');
    ucommit=$(echo "$line" | cut -d\; -f3);
    dcommit=$(echo "$line" | cut -d\; -f7);
    dfile=$(echo "$dcommit" | 
        ~/lookup/cmputeDiff3.perl 2>/dev/null |
        grep "$blob" |
        head -1 |
        cut -d\; -f2 |
        sed 's|,|-|g');
    dt=$(echo "$line" | cut -d\; -f8);
    ddate=$(date -d @"$dt" | awk '{print $2" "$3" "$6}');
    down_url=$(echo "$line" |
        cut -d\; -f5 |
        sed 's|_|/|;s|^|https://github.com/|');
    echo "$name,$email,$blob,$up_url,$udate,$ucommit,$down_url,$ddate,$dcommit,$dfile"
done >> data/survey/second/can_down.csv;

# checking same authors
LC_ALL=C LANG=C join -t\; -2 2 \
    <(zcat data/survey/second/can.4.ks |
        cut -d\; -f1,2,5,6,7,8,11) \
    <(zcat data/survey/second/can.d.A2kcte.s |
        ~/lookup/lsort 10G -t\; -k2,2 -u) >tmp;
cut -d\; -f3,8 <tmp >a1a2; # n 14442 ; $1==$2 1593
cut -d\; -f2 <na1a2 | ~/lookup/getValues a2A >a1A1;
cut -d\; -f3 <na1a2 | ~/lookup/getValues a2A >a2A2;
LC_ALL=C LANG=C join -t\; \
    <(~/lookup/lsort 10G -t\; -k1 <a1a2) \
    <(~/lookup/lsort 10G -t\; -k1 -u <a1A1) |
awk -F\; '{print $3";"$2}'>A1a2;
LC_ALL=C LANG=C join -t\; -1 2 \
    <(~/lookup/lsort 10G -t\; -k2 <A1a2) \
    <(~/lookup/lsort 10G -t\; -k1 -u <a2A2) |
awk -F\; '{print $2";"$3}'>A1A2; # $1==$2 4243
