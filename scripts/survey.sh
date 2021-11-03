#!/usr/bin/bash

#small to big
for i in {0..31}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($2<10 && $4==0 && $16>10 && $18>10) print}'
done |
gzip > ../data/survey/sTb.gz;
#big to big
for i in {8..15}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    awk -F\; '{if ($2>10 && $4>10 && $16>10 && $18>10) print}'
done |
gzip > ../data/survey/bTb.gz;
#big to small
zcat /da5_data/basemaps/gz/annote16.gz |
awk -F\; '{if ($2>10 && $4>10 && $16<10 && $18==0) print}' |
gzip > ../data/survey/bTs.gz;
#small to small
zcat /da5_data/basemaps/gz/annote24.gz |
awk -F\; '{if ($2<10 && $4==0 && $16<10 && $18==0) print}' |
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
echo "audris_up-repo;0;0;0;0;0;0;0;0;0;audris-blob;0;0;0;audris_down-repo;0;0;0;0;0;0;0;0;0;0;0;\
    audris-up-commit;audris-up-date;audris upstream <audris@utk.edu>;audris-up-filename;\
    audris-down-commit;audris-down-date;audris downstream <audris@utk.edu>;audris-down-filename"\
>> ../data/survey/initial/candidates.final;
echo "mahmoud_up-repo;0;0;0;0;0;0;0;0;0;mahmoud-blob;0;0;0;mahmoud_down-repo;0;0;0;0;0;0;0;0;0;0;0;\
    mahmoud-up-commit;mahmoud-up-date;mahmoud upstream <mjahansh@vols.utk.edu>;mahmoud-up-filename;\
    mahmoud-down-commit;mahmoud-down-date;mahmoud downstream <mahmoud.jahanshahi@gmail.com>;mahmoud-down-filename"\
>> ../data/survey/initial/candidates.final;
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
