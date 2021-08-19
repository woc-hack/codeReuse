while read line; do
	echo;
	#line=$(</dev/stdin);
	echo $line;
	b=$(echo $line | cut -d\; -f11);
	p1=$(echo $line | cut -d\; -f1);
	p2=$(echo $line | cut -d\; -f15);
	echo "blob:"
	echo $b;
	echo "from:";
	echo $p1;
	echo "to:";
	echo $p2;

	#b2f
	echo "files:";
	echo $b | ~/lookup/getValues -f b2f | head ;

	#commit in p1
	echo "commits in p1:";
	echo $b | ~/lookup/getValues -f b2c | cut -d\; -f2 | 
	~/lookup/getValues -f c2p | grep $p1 | 
	sort | uniq | head | cut -c1-7;

	#commit in p2
	echo "commits in p2:";
	echo $b | ~/lookup/getValues -f b2c | cut -d\; -f2 | 
	~/lookup/getValues -f c2p | grep $p2 | 
	sort | uniq | head | cut -c1-7;
	echo "commits in p2 using ob2b1:";
	echo $b | ~/lookup/getValues -f ob2b | cut -d\; -f2 |
	~/lookup/getValues -f b2c | cut -d\; -f2 | 
	~/lookup/getValues -f c2p | grep $p2 | 
	sort | uniq | head | cut -c1-7;
	echo "commits in p2 using ob2b2:";
	echo $b | ~/lookup/getValues -f ob2b | cut -d\; -f2 | 
	~/lookup/getValues -f ob2b | cut -d\; -f2 | 
	~/lookup/getValues -f b2c | cut -d\; -f2 | 
	~/lookup/getValues -f c2p | grep $p2 |
	sort | uniq | head | cut -c1-7;
	echo "commits in p2 using ob2b3:";
	echo $b | ~/lookup/getValues -f ob2b | cut -d\; -f2 | 
	~/lookup/getValues -f ob2b | cut -d\; -f2 | 
	~/lookup/getValues -f ob2b | cut -d\; -f2 | 
	~/lookup/getValues -f b2c | cut -d\; -f2 | 
	~/lookup/getValues -f c2p | grep $p2 | 
	sort | uniq | head | cut -c1-7;
	
#	#projects with most stars
#	echo "project with most stars containing this blob:";
#	echo $b |~/lookup/getValues -f b2c | cut -d\; -f2 | 
#	~/lookup/getValues -f c2p | cut -d\; -f2 >/tmp/mj;
#	zcat /da5_data/basemaps/gz/ght.watchers.date.gz | grep -Ff /tmp/mj | 
#	cut -d\; -f1 | uniq -c | sort -nr -k1,1 | head;
done

