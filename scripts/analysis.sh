#!/usr/bin/bash

#copied blobs
ver=U;
i=14;
dir="/nics/b/home/audris/work/c2fb/";
zcat ${dir}b2tPFull${ver}$i.s | 
cut -d\; -f1,3 | 
uniq | 
~/lookup/lsort 10G -u | 
cut -d\; -f1 | 
uniq -d | 
gzip > data/blobs/b2tPFull${ver}$i.copied;

dir="/nics/b/home/audris/work/All.blobs/";
zcat ${dir}b2slfclFull${ver}$i.s | 
join -t\; - <(zcat data/blobs/b2tPFull${ver}$i.copied) | 
gzip > data/blobs/b2tPFull${ver}$i.copiedSize;
zcat ${dir}b2slfclFull${ver}$i.s | 
join -v1 -t\; - <(zcat data/blobs/b2tPFull${ver}$i.copied) | 
gzip > data/blobs/b2tPFull${ver}$i.notCopiedSize;
