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

  