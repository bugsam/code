#!/bin/bash

ROWS=63
COLUMNS=100

read LINE

if [[ $LINE -eq 1 ]]
then
    #line
    for (( x=1; x<=(ROWS/2); x++))
    do
        for (( i=0; i<COLUMNS; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done
fi


if [[ $LINE -eq 2 ]]
then
    
    let "BEG=(ROWS/4)+10"
    let "MED=(ROWS/4)"
    let "INT=(ROWS/4)"
    let "END=BEG+1"
    
    #line
    for (( x=1; x<=(ROWS/4); x++))
    do
        for (( i=0; i<COLUMNS; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done

    #first
    for (( x=0; x<=ROWS/8; x++))
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
    
        for (( i=0; i<INT; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "INT++"
        let "INT++"
        
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
fi


let "BEG=(ROWS/2)+2"
let "MED=(ROWS/2)"
let "END=BEG+1"

#base
for (( x=0; x<=ROWS/8; x++))
do
    for (( i=0; i<BEG; i++ ))
    do
        printf "_"
    done
    printf "1"
    
    for (( i=0; i<MED; i++ ))
    do
        printf "_"
    done
    printf "1"

    for (( i=0; i<END; i++ ))
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
