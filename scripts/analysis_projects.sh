#!/usr/bin/bash

ver=U;
s=14;

#not used, P2fb is not a good place to start!
#project sample
zcat /da?_data/basemaps/gz/P2fbFull${ver}$s.s |
cut -d\; -f2 |
~/lookup/lsort 50G -u \
> data/projects/P2fbFull${ver}$s.blobs.s;
#b2tc
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        data/projects/P2fbFull${ver}$s.blobs.s \
        <(zcat /da?_data/basemaps/gz/b2taFull${ver}"$i".s | cut -d\; -f1,2,4);
done |
~/lookup/lsort 50G -t\; -k3,3 \
>data/projects/b2tc${ver}$s.cs;
#c2P
cut -d\; -f3 <data/projects/b2tc${ver}$s.cs |
uniq >data/projects/b2tc${ver}$s.commits.s
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        data/projects/b2tc${ver}$s.commits.s \
        <(zcat /da?_data/basemaps/gz/c2PFull${ver}"$i".s);
done >data/projects/c2P${ver}$s.s;
#b2tP
LC_ALL=C LANG=C join -t\; -1 3 \
    data/projects/b2tc${ver}$s.cs \
    data/projects/c2P${ver}$s.s |
cut -d\; -f2-4 |
~/lookup/lsort 100G -t\; -k1,1 \
>data/projects/b2tP${ver}$s.s;
#times
echo "end" >> data/projects/b2tP${ver}$s.s;
perl -e '$pb="";
    while(<STDIN>){
        chop();
        ($bl,$t,$p)=split(/;/);
        if($bl ne $pb && $pb ne ""){
            print "$pb";
            for $pp (sort {$tmp{$a} <=> $tmp{$b} } keys %tmp){
                print ";$pp;$tmp{$pp}"
            }%tmp=();
            print "\n"
        };
        $pb=$bl;
        $tmp{$p}=$t if !defined $tmp{$p} || $tmp{$p} > $t;
    }
' <data/projects/b2tP${ver}$s.s \
>data/projects/b2tP${ver}$s.times ;

#sampling projects
##project_sample.py
#parsing mongo file
##$p;$ncmt;$nblob;$na;$ncore;$nmc;$nf;$cs;$nfr;$gm;$gf;$et;$lt
jq -c '.[]' data/projects/sample.mongo |
while read -r obj; do
    p=$(echo "$obj" | jq .ProjectID | cut -d\" -f2);
    ncmt=$(echo "$obj" | jq .NumCommits);
    nblob=$(echo "$obj" | jq .NumBlobs);
    na=$(echo "$obj" | jq .NumAuthors);
    ncore=$(echo "$obj" | jq .NumCore);
    nmc=$(echo "$obj" | jq .NumActiveMon);
    nf=$(echo "$obj" | jq .NumFiles);
    cs=$(echo "$obj" | jq .CommunitySize);
    nfr=$(echo "$obj" | jq .NumForks);
    gm=$(echo "$obj" | jq .Gender.male);
    gf=$(echo "$obj" | jq .Gender.female);
    et=$(echo "$obj" | jq .EarliestCommitDate);
    lt=$(echo "$obj" | jq .LatestCommitDate);
    echo "$p;$ncmt;$nblob;$na;$ncore;$nmc;$nf;$cs;$nfr;$gm;$gf;$et;$lt";
done |
~/lookup/lsort 20G -t\; -k1,1 \
>data/projects/sample.s;
