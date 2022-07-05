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
perl -e '$pb="";
    while(<STDIN>){
        chop();
        ($bl,$t,$p)=split(/;/);
        if($bl ne $pb || $pb eq ""){
            print "$bl;$t;$p\n"
        }$pb=$bl;
    }' |
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
    }' | 
gzip > 	b2tPFull${ver}$i.times ;
#1-2 year
for d in {31536000,63072000}; do
    zcat data/blobs/b2tPFull${ver}$i.times | 
    awk -F\; -v d="$d" '{l=$3+d;for (i=NF; i>=3; i=i-2) {if( $i>l) continue; else {b=i; break}}; 
        for (j=1; j<=b; ++j) {printf $j";";} print ""}' \
    >times"$d";
done;
#b2tPc
zcat data/blobs/b2tPFull${ver}$i.times |
awk -F\; '{if (NF>3) {print $0";"1} else {print $0";"0}}' >data/blobs/b2tPcFull${ver}$i.0y;
awk -F\; '{if (NF>4) {print $0 1} else {print $0 0}}' <times31536000 >data/blobs/b2tPcFull${ver}$i.1y;
awk -F\; '{if (NF>4) {print $0 1} else {print $0 0}}' <times63072000 >data/blobs/b2tPcFull${ver}$i.2y;
#b2sltPc
for d in {0,1,2}; do
    join -t\; \
        <(zcat data/blobs/b2slfclFull${ver}$i.s | cut -d\; -f1-3) \
        data/blobs/b2tPcFull${ver}$i."$d"y \
    > data/blobs/b2sltPcFull${ver}$i."$d"y;
done;
#sltc
for d in {0,1,2}; do
    awk -F\; '{OFS=";"; print $2,$3,$5,$NF}' <data/blobs/b2sltPcFull${ver}$i."$d"y \
    >data/blobs/"$d"y.$i;
done;

#slurm
ver=U;
s=14;
dir="/nfs/home/audris/work/c2fb/";
zcat ${dir}b2tPFull${ver}$s.s | 
cut  -d\; -f1 |
uniq |
gzip >data/bsample.blobs.s;
#times
dir="/nfs/home/audris/work/c2fb/";
zcat ${dir}b2tPFull${ver}$s.s | 
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
    }' | 
gzip >data/bsample.b2Pt.times;
#1-2 year
#b2Ptc
zcat data/bsample.b2Pt.times |
awk -F\; '{if (NF>3) {print $0";"1} else {print $0";"0}}' |
gzip >data/bsample.b2Ptc.0y &&
echo "finished b2Ptc 0";
i=1;
bound=1619874000;
for d in {31536000,63072000}; do
    zcat data/bsample.b2Pt.times |
    awk -F\; -v d="$d" '{l=$3+d;for (i=NF; i>=3; i=i-2) {if($i<=l) {b=i; break}}; 
        for (j=1; j<=b; ++j) {printf $j";";} print ""}' |
    awk -F\; '{if (NF>4) {print $0 1} else {print $0 0}}' |
    awk -F\; -v bound="$bound" '{if ($3<bound) print}' |
    gzip >data/bsample.b2Ptc.${i}y &&
    echo "finished b2Ptc $i";
    i=2;
    bound=1588338000;
done;
#b2sl
dir="/nfs/home/audris/work/All.blobs/";
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/bsample.blobs.s) \
        <(zcat "${dir}b2slfclFull${ver}$i.s" | cut -d\; -f1-3) 
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/bsample.b2sl.s &&
echo "finished b2sl join";
LC_ALL=C LANG=C join -t\; -a1 -o auto -e null \
    <(zcat data/bsample.blobs.s) \
    <(zcat data/bsample.b2sl.s) |
gzip >tmp;
mv tmp data/bsample.b2sl.s &&
echo "finished b2sl";
#b2slPtc
for i in {0..2}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/bsample.b2sl.s) \
        <(zcat "data/bsample.b2Ptc.${i}y") |
    gzip >"data/bsample.b2slPtc.${i}y" &&
    echo "finished b2slPtc $i";
done;
#b2sltcd
for i in {0..2}; do
    zcat "data/bsample.b2slPtc.${i}y" |
    awk -F\; '{OFS=";"; print $1,$2,$3,$5,$NF,(NF-6)/2}' |
    gzip >"data/bsample.b2sltcd.${i}y" &&
    echo "finished b2sltcd $i";
done;
#sltcd
#$size;$language;$time;$copied;$downstream
for i in {0..2}; do
    zcat "data/blobs/bsample.b2sltcd.${i}y" |
    awk -F\; '{OFS=";"; print $2,$3,$4,$5,$6}' \
    >"data/blobs/bsample.sltcd.${i}y" &&
    echo "finished sltcd $i";
done;
