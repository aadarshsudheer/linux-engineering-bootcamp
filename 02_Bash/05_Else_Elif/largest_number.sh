#!/bin/bash
read -p "Enter Two Numbers: " FIRST LAST
if [ "$FIRST" -gt "$LAST" ]
then	echo "$FIRST is the Largest"
elif [ "$LAST" -gt "$FIRST" ]
then	echo "$LAST is the Largest"
else
	echo "Both are equal"
fi
