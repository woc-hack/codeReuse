#!/bin/bash
#SBATCH -A ACF-UTK0011
#SBATCH -J sample.P2summ2
#SBATCH --time=0-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --ntasks-per-node=48
#SBATCH --partition=campus
#SBATCH --output=sample.P2summ2.o%j
#SBATCH --error=sample.P2summ2.e%j

#P2summ
for i in {2..2}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat data/sample.b2sl.s) \
        <(zcat data/sample.b2Ptc.${i}y) |
    gzip >data/sample.b2slPtc.${i}y &&
    echo "finished b2slPtc $i ";
    zcat data/sample.b2slPtc.${i}y |
    awk -F\; '{OFS=";"; print $4,$2,$3,$5,$NF,(NF-6)/2}' |
    LC_ALL=C LANG=C sort -T. -t\; -k1,1 |
    gzip >data/sample.P2sltcd.${i}y &&
    echo "finished P2sltcd $i ";
    echo "end" |
    gzip >>data/sample.P2sltcd.${i}y;
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
            if (!$tmp{c}){
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
    gzip >data/sample.P2summ.${i}y &&
    echo "finished P2summ $i ";
done;
