#!/usr/bin/bash

ver=U
dir="/da7_data/basemaps/gz/"

## copied blobs (B)
for i in {0..127}; do
    zcat "${dir}b2tPFull${ver}$i.s" |
    cut -d\; -f1,3 | 
    uniq |
    LC_ALL=C LANG=C sort -T ./tmp/ -t\; -u |
    cut -d\; -f1 | 
    uniq -d | 
    gzip >"data/b2tPFull${ver}$i.copied"
done
# B2tP
for i in {0..127}; do 
    LC_ALL=C LANG=C join -t\; \
        <(zcat "${dir}b2tPFull${ver}$i.s") \
        <(zcat "data/b2tPFull${ver}$i.copied") |
    gzip >"data/B2tPFull${ver}$i.s"
done

# B2ftP
## first time/project for each copied blob
for i in {0..127}; do 
    zcat "data/B2tPFull${ver}$i.s" |
    perl -e '$pb="";
        while(<STDIN>){
            chop();
            ($b,$t,$p)=split(/;/);
            if($b ne $pb){
                print "$b;$t;$p\n";
                $pb=$b;
            }
        }
    ' |
    gzip >"data/B2ftPFull${ver}$i.s"
done

# B2Pft
## first time in each project
for i in {0..127}; do 
    zcat "data/B2tPFull${ver}$i.s" |
    awk -F\; '{OFS=";";print $1,$3,$2}' |
    LC_ALL=C LANG=C sort -T ./tmp/ -t\; |
    perl -e '$pbp="";
        while(<STDIN>){
            chop();
            ($b,$p,$t)=split(/;/);
            $bp="$b;$p";
            if($bp ne $pbp){
                print "$b;$p;$t\n";
                $pbp=$bp;
            }
        }
    ' |
    gzip >"data/B2PftFull${ver}$i.s"
done;

# PtB2Pt
for i in {0..127}; do 
    LC_ALL=C LANG=C join -t\; -o 1.3 1.2 1.1 2.2 2.3 \
        <(zcat "data/B2ftPFull${ver}$i.s") \
        <(zcat "data/B2PftFull${ver}$i.s") |
    awk -F\; '{if ($1 != $4) print}' |
    gzip >"data/Ptb2PtFull${ver}$i.s"
done
