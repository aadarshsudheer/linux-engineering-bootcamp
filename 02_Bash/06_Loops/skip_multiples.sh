#!/bin/bash
count=1
while [ "$count" -lt 20 ]
do 
	if (("$count"%5==0))
	then
		((count++))	
		continue
	fi
echo "$count"
((count++))
done  
