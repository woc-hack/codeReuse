#!/usr/bin/bash

#------------------------------------------------------------------------------------
#!!!not used, P2fb is not a good place to start!!!
ver=U;
s=14;
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
#------------------------------------------------------------------------------------

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
awk -F\; '{if ($1!="" && $2!="null") print}' |
~/lookup/lsort 20G -t\; -k1,1 \
>data/projects/sample.s;
#adding number of stars
jq '.[] | "\(.ProjectID);\(.NumStars)"' data/projects/sample.mongo >tmpStars;
LC_ALL=C LANG=C join -t\; \
    data/projects/sample.s \
    <(cut -d\" -f2 <tmpStars | 
        awk -F\; '{if (NF==2) print}' |
        ~/lookup/lsort 20G -t\; -k1,1) \
>tmp;
rm tmpStars;
mv tmp data/projects/sample.s;
#copied blobs
for i in {0..31}; do
    LC_ALL=C LANG=C join -t\; \
        <(cut -d\; -f1 <data/projects/sample.s) \
        <(zcat /da?_data/basemaps/gz/P2fbFull${ver}"$i".s) 
done |
~/lookup/lsort 20G -t\; -k1,1 |
gzip >data/projects/sample.P2fb.s;
#slurm
ver=U;
##copied blobs Full
dir="/nfs/home/audris/work/c2fb/";
for i in {0..127}; do 
    zcat ${dir}b2tPFull${ver}$i.s |
    cut -d\; -f1,3 |
    uniq |
    LC_ALL=C LANG=C sort -T. -u |
    cut -d\; -f1 |
    uniq -d |
    gzip >data/b2tPFull${ver}$i.copied;
done;
##not copied Full
for i in {0..127}; do 
    LC_ALL=C LANG=C join -t\; -v1 \
        <(zcat ${dir}b2tPFull${ver}$i.s | cut -d\; -f1,3) \
        <(zcat data/b2tPFull${ver}$i.copied) |
    uniq |
    gzip >data/notCopiedb2PFull${ver}$i.s;
    zcat data/notCopiedb2PFull${ver}$i.s |
    awk -F\; '{print $2";"$1}' |
    LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
    gzip >data/P2notCopiedbFull${ver}$i.s;
done;
#join with sample projects
for i in {0..127}; do 
    LC_ALL=C LANG=C join -t\; \
        <(cut -d\; -f1 <data/sample.s) \
        <(zcat data/P2notCopiedbFull${ver}$i.s)
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.P2notCopiedb.s;
#geting all the sample blobs
for file in {P2fb,P2notCopiedb}; do
    zcat data/sample.${file}.s 
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.P2b.s;
zcat data/sample.P2b.s |
awk -F\; '{print $2";"$1}' |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.b2P.s;
zcat data/sample.b2P.s |
cut -d\; -f1 |
gzip >data/sample.blobs.s;
#joining with b2tP
dir="/nfs/home/audris/work/c2fb/";
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/sample.blobs.s) \
        <(zcat ${dir}b2tPFull${ver}$i.s)
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.b2tP.s;
#creating times
zcat data/sample.b2tP.s | 
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
gzip >data/sample.b2tP.times;
#1-2 year
#b2Ptc
zcat data/sample.b2tP.times |
awk -F\; '{if (NF>3) {print $0";"1} else {print $0";"0}}' |
gzip >data/sample.b2Ptc.0y;
i=1;
bound=1619874000;
for d in {31536000,63072000}; do
    zcat data/sample.b2tP.times |
    awk -F\; -v d="$d" '{l=$3+d;for (i=NF; i>=3; i=i-2) {if($i<=l) {b=i; break}}; 
        for (j=1; j<=b; ++j) {printf $j";";} print ""}' |
    awk -F\; '{if (NF>4) {print $0 1} else {print $0 0}}' |
    awk -F\; -v bound="$bound" '{if ($3<bound) print}' |
    gzip >data/sample.b2Ptc.${i}y;
    i=2;
    bound=1588338000;
done;
#b2sl
dir="/nfs/home/audris/work/All.blobs/";
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/sample.blobs.s) \
        <(zcat ${dir}b2slfclFull${ver}$i.s | cut -d\; -f1-3) 
done |
LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
gzip >data/sample.b2sl.s;
LC_ALL=C LANG=C join -t\; -a1 -o auto -e null \
    <(zcat data/sample.blobs.s) \
    <(zcat data/sample.b2sl.s) |
gzip >tmp;
mv tmp data/sample.b2sl.s;
#b2slPtc
for i in {0..2}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/sample.b2sl.s) \
        <(zcat data/sample.b2Ptc.${i}y) |
    gzip >data/sample.b2slPtc.${i}y;
done;
#P2sltcd
for i in {0..2}; do
    zcat data/sample.b2slPtc.${i}y |
    awk -F\; '{OFS=";"; print $4,$2,$3,$5,$NF,(NF-6)/2}' |
    LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
    gzip >data/sample.P2sltcd.${i}y;
    echo "end" |
    gzip >>data/sample.P2sltcd.${i}y;
done;
#P2summ
#P2$language$blobCount$copiedbCount$binarybCount$binaryCopiedbCount$averageDownstreamCount$averageSize$averageCopiedSize$earliestTime
for i in {0..2}; do
    zcat data/sample.P2sltcd.${i}y |
    perl -e '$pp="";
        while(<STDIN>){
            chop();
            ($p,$s,$l,$t,$c,$d)=split(/;/);
            if($p ne $pp && $pp ne ""){
                $maxl=0;
                $bl="null";
                for $ll (keys %tmpl){
                    if ($tmpl{$ll} > $maxl){
                        $bl=$ll;
                        $maxl=$tmpl{$ll};
                    };
                };
                if (($tmp{c}-$tmp{bc}) != 0){
                    $tmp{as}=$tmp{s}/($tmp{c}-$tmp{bc});
                } else {$tmp{as}="null"};
                if (($tmp{cc}-$tmp{bcc}) != 0){
                    $tmp{acs}=$tmp{cs}/($tmp{cc}-$tmp{bcc});
                } else {$tmp{acs}="null"};
                if ($tmp{cc} != 0){
                    $tmp{ad}=$tmp{d}/$tmp{cc};
                } else {$tmp{ad}="null"};
                print "$pp;$bl;$tmp{c};$tmp{cc};$tmp{bc};$tmp{bcc};$tmp{ad};$tmp{as};$tmp{acs};$tmp{et}\n";
                %tmp=();
                %tmpl=();
            };
            if (!defined $tmp{c}){
                $tmp{c}=0;
                $tmp{cc}=0;
                $tmp{bc}=0;
                $tmp{bcc}=0;
                $tmp{s}=0;
                $tmp{cs}=0;
                $tmp{d}=0;
            };
            $pp=$p;
            $tmp{c}++;
            $tmp{cc}+=$c;
            $tmp{d}+=$d;
            if($s=="null"){
                $tmp{bc}++;
                $tmp{bcc}+=$c;
            }else{
                $tmp{s}+=$s;
                $tmp{cs}+=$s if $c==1;
                $tmpl{$l}+=1;
            };
            $tmp{et}=$t if (!defined $tmp{et} || $tmp{et} > $t);
    }' |
    gzip >data/sample.P2summ.${i}y;
done;
#P2all
#1$p;2$ncmt;3$nblob;4$na;5$ncore;6$nmc;7$nf;8$cs;9$nfr;10$gm;11$gf;12$et;13$lt;14$ns
#15$l;16$nb;17$cc;18$bc;19$bcc;20$ad;21$as;22$acs;23$ebt
for i in {0..2}; do
    LC_ALL=C LANG=C join -t\; \
        data/projects/sample.s \
        <(zcat "data/projects/sample.P2summ.${i}y") \
    > "data/projects/sample.P2all.${i}y";
done;
