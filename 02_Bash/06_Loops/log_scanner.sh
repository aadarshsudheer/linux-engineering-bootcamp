#!/bin/bash
for log in app.log server.log database.log backup.log
do echo "checking "$log" ..."
	if [ "$log" = database.log ]
	then
	 echo "error found." 
	 echo "Moving to the next file"
	break
	fi
 echo "no error"
done
