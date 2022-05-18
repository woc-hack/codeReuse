#!/usr/bin/bash

# getting uniq projects from annote files
# project;Ncopy
for i in {0..1}; do
    zcat /da5_data/basemaps/gz/annote$i.gz |
    cut -d\; -f1-4,7-9 |
    ~/lookup/lsort 20G |
    uniq -c |
    awk '{print $2";"$1}' |
    ~/lookup/lsort 10G -t\; -k1,1 \
    > ../data/projects/uP.$i;
    zcat /da5_data/basemaps/gz/annote$i.gz |
    cut -d\; -f15-18,21-23 |
    ~/lookup/lsort 20G |
    uniq -c |
    awk '{print $2";"$1}' \
    > ../data/projects/dP.$i;
done;

# parsing random projects
# not used/ too slow
for i in {0..29}; do
    file="../data/projects/projects$i.json";
    for j in {0..29999}; do
        obj=$(  cat $file |
                jq .cursor.firstBatch |
                jq .[$j]
        );
        p=$(echo $obj | jq .ProjectID | cut -d\" -f2);
        nc=$(echo $obj | jq .NumCommits);
        nb=$(echo $obj | jq .NumBlobs);
        nob=$(echo $obj | jq .NumOriginalBlobs);
        nfi=$(echo $obj | jq .NumFiles);
        na=$(echo $obj | jq .NumAuthors);
        ncore=$(echo $obj | jq .NumCore);
        nfo=$(echo $obj | jq .NumForks);
        nm=$(echo $obj | jq .NumActiveMon);
        lt=$(echo $obj | jq .LatestCommitDate);
        echo "$p;$nc;$nb;$nob;$nfi;$na;$ncore;$nfo;$nm;$lt";
    done;
done > ../data/projects/projects;

# random sample of projects
for i in {0..31}; do
    zcat /da?_data/basemaps/gz/P2AFullU"$i".s |
    shuf -n 30000 |
    cut -d\; -f1 |
    ~/lookup/lsort |
    uniq;
done |
~/lookup/lsort 30G |
uniq > data/projects/Psample;
## joining with annote
for i in {0..31}; do
    LC_ALL=C LANG=C join -t\; \
        data/projects/Psample \
        <(zcat /da5_data/basemaps/gz/annote"$i".gz) \
    > data/projects/split/Psample."$i";
done;
## P;nmc;nblob;nsa;ncore;ncmt;na;Ncopy
for i in {0..31}; do
    cut -d\; -f1-4,7-9 <data/projects/split/Psample."$i" |
    ~/lookup/lsort 50G |
    uniq -c |
    awk '{print $2";"$1}' \
    > data/projects/split/P."$i";
done;
~/lookup/lsort 20G -t\; -k1,1 <data/projects/split/P.* >data/projects/uP.p;
## no copy projects
LC_ALL=C LANG=C comm -23 \
    data/projects/Psample \
    <(cut -d\; -f1 <data/projects/uP.p) \
>data/projects/nP.p;
## parsing mongo file
jq -c '.[]' data/projects/nP.mongo |
while read -r obj; do
    p=$(echo "$obj" | jq .ProjectID | cut -d\" -f2);
    ncmt=$(echo "$obj" | jq .NumCommits);
    nblob=$(echo "$obj" | jq .NumBlobs);
    na=$(echo "$obj" | jq .NumAuthors);
    ncore=$(echo "$obj" | jq .NumCore);
    nmc=$(echo "$obj" | jq .NumActiveMon);
    echo "$p;$nmc;$nblob;$ncore;$ncmt;$na";
done >data/projects/nPa.p;
## getting stars
LC_ALL=C LANG=C join -t\; \
    <(cut -d\; -f1 <data/projects/nPa.p | ~/lookup/lsort 30G) \
    <(zcat /da5_data/basemaps/gz/ght.P2w.cnt | ~/lookup/lsort 50G -t\; -k1,1) \
>data/projects/nPs.p;
## consolidating
## P;nmc;nblob;ncore;ncmt;na;Ncopy
cut -d\; -f4 --complement <data/projects/uP.p \
>data/projects/cP.p;
sed 's|$|;0|' <data/projects/nPa.p \
>>data/projects/cP.p;
