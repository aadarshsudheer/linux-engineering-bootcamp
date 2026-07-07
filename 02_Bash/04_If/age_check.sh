read -p "User Age: " AGE

if [ "$AGE" -ge 18 ]
then
	echo "Access Granted"
else
	echo "Access Denied"
fi
