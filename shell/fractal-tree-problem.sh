#!/bin/bash

ROWS=63
COLUMNS=100

read LINE

let "BEG=(ROWS/2)+2"
let "MED=(ROWS/2)"
let "END=BEG+1"

#base2
for (( x=1; x<=(ROWS/2); x++))
do
    for (( i=0; i<COLUMNS; i++ ))
    do
        printf "_"
    done
    printf "\n"
done


#first
for (( x=0; x<=ROWS/4; x++))
do
    for (( i=0; i<BEG; i++ ))
    do
        printf "_"
    done
    printf "1"
    let "BEG++"
    
    for (( i=0; i<MED; i++ ))
    do
        printf "_"
    done
    printf "1"
    let "MED--"
    let "MED--"

    for (( i=0; i<END; i++ ))
    do
        printf "_"
    done
    printf "\n"
    let "END++"
done

#base
for (( x=0; x<=ROWS/4; x++))
do
    for (( i=0; i<(COLUMNS/2-1); i++ ))
    do
        printf "_"
    done
        printf "1"
    for (( i=0; i<COLUMNS/2; i++ ))
    do
        printf "_"
    done
    if [[ $x -le 14 ]]
    then
        printf "\n"
    fi
done
