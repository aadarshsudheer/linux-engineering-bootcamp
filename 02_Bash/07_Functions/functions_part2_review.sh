#!/bin/bash
Name="Aadarsh"
greet() {
	local Name="Alex"
	echo "Inside the function : $Name "
	return 0
}
greet
echo "Outside the function : $Name"

status=$?

echo "Exit status: $status"
