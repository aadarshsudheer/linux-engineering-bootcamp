#!/bin/bash

add() {
    echo "First number : $1"
    echo "Second number: $2"
    echo "Result       : $(( $1 + $2 ))"
}

add 10 20
