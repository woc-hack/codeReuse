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

#initial survey
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
    done > ../data/survey/initial/$set.2
done

