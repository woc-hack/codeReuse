#!/usr/bin/bash

ver=U;
i=14;

#copied blobs
dir="/nics/b/home/audris/work/c2fb/";
zcat ${dir}b2tPFull${ver}$i.s | 
cut -d\; -f1,3 | 
uniq | 
~/lookup/lsort 10G -u | 
cut -d\; -f1 | 
uniq -d | 
gzip > data/blobs/b2tPFull${ver}$i.copied;
#b2slfcl
dir="/nics/b/home/audris/work/All.blobs/";
zcat ${dir}b2slfclFull${ver}$i.s | 
join -t\; - <(zcat data/blobs/b2tPFull${ver}$i.copied) | 
gzip > data/blobs/b2tPFull${ver}$i.copiedSize;
zcat ${dir}b2slfclFull${ver}$i.s | 
join -v1 -t\; - <(zcat data/blobs/b2tPFull${ver}$i.copied) | 
gzip > data/blobs/b2tPFull${ver}$i.notCopiedSize;

#creation time
#b2tPc
dir="/nics/b/home/audris/work/c2fb/";
zcat ${dir}b2tPFull${ver}$i.s | 
perl -e '$pb="";while(<STDIN>){chop();($bl,$t,$p)=split(/;/);if($bl ne $pb || $pb eq ""){print "$bl;$t;$p\n"}$pb=$bl;}' |
join -t\; -a1 - <(zcat data/blobs/b2tPFull${ver}$i.copied | awk '{print $1";1"}') | 
awk -F\; '{if (NF==3) print $0";0"; else print $0}' | 
gzip > data/blobs/b2tPFull${ver}$i.FirstCopied;
#b2tPcslfcl
dir="/nics/b/home/audris/work/All.blobs/"
zcat data/blobs/b2tPFull${ver}$i.FirstCopied | 
join -t\; - <(zcat ${dir}b2slfclFull${ver}$i.s) | 
gzip > /lustre/haven/user/mjahansh/b2tPFull${ver}$i.FirstCopiedSize;
#transfer
tar -cf - \
    /lustre/haven/user/mjahansh/b2tPFull${ver}$i.FirstCopiedSize \
    data/blobs/b2tPFull${ver}$i.FirstCopied |
gzip -c | ssh -p 443 mjahansh@da4.eecs.utk.edu tar -xzf -

#times
zcat b2tPFull${ver}$i.s | 
perl -e '$pb="";
    while(<STDIN>){chop();($bl,$t,$p)=split(/;/);
    if($bl ne $pb && $pb ne ""){print "$pb";for $pp (sort {$tmp{$a} <=> $tmp{$b} } keys %tmp){print ";$pp;$tmp{$pp}"}%tmp=();print "\n"};$pb=$bl;$tmp{$p}=$t if !defined $tmp{$p} || $tmp{$p} > $t;}' | 
gzip > 	b2tPFull${ver}$i.times ;
#1-2 year
for d in {31536000,63072000}; do
    zcat data/blobs/b2tPFullU14.times | 
    awk -F\; -v d="$d" '{l=$3+d;for (i=NF; i>=3; i=i-2) {if( $i>l) continue; else {b=i; break}}; for (j=1; j<=b; ++j) {printf $j";";} print ""}' \
    >times"$d";
done;
#b2tPc
zcat data/blobs/b2tPFullU14.times |
awk -F\; '{if (NF>3) {print $0";"1} else {print $0";"0}}' >data/blobs/b2tPcFullU14.0y;
awk -F\; '{if (NF>4) {print $0 1} else {print $0 0}}' <times31536000 >data/blobs/b2tPcFullU14.1y;
awk -F\; '{if (NF>4) {print $0 1} else {print $0 0}}' <times63072000 >data/blobs/b2tPcFullU14.2y;
#b2sltPc
for d in {0,1,2}; do
    join -t\; \
        <(zcat data/blobs/b2slfclFullU14.s | cut -d\; -f1-3) \
        data/blobs/b2tPcFullU14."$d"y \
    > data/blobs/b2sltPcFullU14."$d"y;
done;
#sltc
for d in {0,1,2}; do
    awk -F\; '{OFS=";"; print $2,$3,$5,$NF}' <data/blobs/b2sltPcFullU14."$d"y \
    >data/blobs/"$d"y.14;
done;
