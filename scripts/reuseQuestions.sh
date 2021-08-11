#!/usr/bin/bash

echo "Usage: codeReuse.sh REPO"
echo;
echo "Before starting, please make sure that you have pulled the latest version of lookup!";

repo=$1;


#Q1
echo;
echo "Q1: Inspect the README at project's URL:";
echo $repo | sed 's/^/https:\/\/github.com\//;s/_/\//';
echo;


#Q2
echo "Q2: See months active in general info section of spreadsheet."
echo;

#Q3
echo "Q3: Look at the result of following command:";
echo "echo $repo | ~/lookup/getValues -f P2f | cut -d\; -f2 | sed 's/.*\///' | grep '\.' | sed 's/.*\.//' | /home/audris/bin/lsort 1G | uniq -c | sort -n | sed 's/ *//'"
echo;

#Q4
echo "Q4: Look at the result of following command:";
echo "~/lookup/mostShared.sh $repo | sort -t\; -n -k5 > $repo.mostShared ; cat $repo.mostShared"
echo;

#Q5
echo "Q5: Look at the results of Q4 and think:";
echo "cat $repo.mostShared";
echo;

#Q6
echo "Q6: Think! You can also look at the reslut of following command:";
echo "cat $repo.mostShared | tail | cut -d\; -f3 | ~/lookup/getValues -f b2P | cut -d\; -f2 | sort | uniq -c | sort -nr | head | rev | cut -d\" \" -f1 | rev | sed 's/^/https:\/\/github.com\//;s/_/\//'"
echo;

#Q7
echo "Q7: Look at the result of following command. The result format is:"
echo "BlobOriginatinRep;type;inDegree;outDegree;nblobs;nOrigBlobs;sharedBlobs;BlobUsingRepo;type;inDegree;outDegree;nblobs;nOrigBlobs;sharedBlobsBacktoOriginatingRepo"
echo;
echo "If this is overal sample, use this command: zcat /da5_data/basemaps/gz/search.out | grep $repo | sort -t\; -n -k7"
echo "If this is excluding 100+ sample, use this command: zcat /da5_data/basemaps/gz/searchL.out | grep $repo | sort -t\; -n -k7"
echo;

#Q8
echo "Q8: Look at the results of Q5, Q6 and Q7 and investigate."
echo;

#Q9
echo "Q9: Investigate and think."
echo;

#Q10
echo "Q10: Investigate and think."
echo;

#Q11
echo "Q11: Investigate and think."
echo;

#Q12
echo "Q12: Look at the result of following command. The result format is:"
echo "BlobOriginatinRep;type;inDegree;outDegree;nblobs;nOrigBlobs;sharedBlobs;BlobUsingRepo;type;inDegree;outDegree;nblobs;nOrigBlobs;sharedBlobsBacktoOriginatingRepo"
echo;
echo "If this is overal sample, use this command: zcat /da5_data/basemaps/gz/search.in | grep $repo | sort -t\; -n -k7"
echo "If this is excluding 100+ sample, use this command: zcat /da5_data/basemaps/gz/searchL.in | grep $repo | sort -t\; -n -k7"
echo;

#Q13
echo "Q13: Look at the result of following command:";
echo "~/lookup/mostWidelyUsed.sh $repo > $repo.mostUsed; cat $repo.mostUsed"
echo;

#Q14
echo "Q14: Look at the results of Q13 and think:";
echo "cat $repo.mostUsed";
echo;

#Q15
echo "Q15: Look at the results of Q12 and Q13 and investigate."
echo;

#Q16
echo "Q10: Investigate and think."
echo;

#Q17
echo "Q17: Investigate and think."
echo;

