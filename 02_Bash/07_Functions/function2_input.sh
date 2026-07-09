#!/bin/bash

greet() {
    echo "Inside function"
    echo "\$1 = $1"
    echo "\$2 = $2"
    echo
}

greet Aadarsh Rahul

greet John Mike
