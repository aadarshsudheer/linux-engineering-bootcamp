#!/bin/bash
read -p "Username: " NAME
if [ "$NAME" = admin ]
then 	echo "Welcome Administrator"

else	
	echo "Unknown User"
fi
