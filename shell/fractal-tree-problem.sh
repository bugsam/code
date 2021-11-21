#!/bin/bash

ROWS=63
COLUMNS=100

read LINE


if [[ $LINE -gt 1 ]]
then
    
    let "LINE1=(ROWS/3)+4"
    let "LINE24=(ROWS/4)"
    let "LINE3=(ROWS/4)"
    let "LINE5=LINE1+1"
    
    #headerTwo
    for (( x=1; x<=(ROWS/4); x++))
    do
        for (( i=0; i<COLUMNS; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done

    #Two
    for (( x=0; x<=ROWS/8; x++))
    do
        for (( i=0; i<LINE1; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "LINE1++"
    
    
        for (( i=0; i<LINE24; i++ ))
        do
            printf "_"
        done
        printf "1"
    
        for (( i=0; i<LINE3; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "LINE3++"
        let "LINE3++"
        
        for (( i=0; i<LINE24; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "LINE24--"
        let "LINE24--"
    
        for (( i=0; i<LINE5; i++ ))
        do
            printf "_"
        done
        printf "\n"
        let "LINE5++"
    done
    
    let "LINE1=(ROWS/2)+2"
    let "LINE2=(ROWS/2)"
    let "LINE3=LINE1+1"

    #baseTwo
    for (( x=0; x<=ROWS/8; x++))
    do
        for (( i=0; i<LINE1; i++ ))
        do
            printf "_"
        done
        printf "1"
        
        for (( i=0; i<LINE2; i++ ))
        do
            printf "_"
        done
        printf "1"
    
        for (( i=0; i<LINE3; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done
fi



if [[ $LINE -eq 1 ]]
then
    #headerOne
    for (( x=1; x<=(ROWS/2); x++))
    do
        for (( i=0; i<COLUMNS; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done
fi

#footer
let "LINE1=(ROWS/2)+2"
let "LINE2=(ROWS/2)"
let "LINE3=LINE1+1"

#One
for (( x=0; x<=ROWS/4; x++))
do
    for (( i=0; i<LINE1; i++ ))
    do
        printf "_"
    done
    printf "1"
    let "LINE1++"
    
    for (( i=0; i<LINE2; i++ ))
    do
        printf "_"
    done
    printf "1"
    let "LINE2--"
    let "LINE2--"

    for (( i=0; i<LINE3; i++ ))
    do
        printf "_"
    done
    printf "\n"
    let "LINE3++"
done

#baseOne
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
