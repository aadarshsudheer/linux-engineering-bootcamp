#!/bin/bash
for fruits in apple mango orange banana
do 
	if [ "$fruits" = "orange" ]	
	then
	echo "Found Orange!"	
	break
	
	fi
done
