#!/bin/bash

ROWS=63
COLUMNS=100

read LINE

if [[ $LINE -gt 2 ]]
then
    #headerThree
    for (( x=1; x<=(ROWS/9); x++))
    do
        for (( i=0; i<COLUMNS; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done

    #Three
    let "LINE1=(ROWS/3)"
    let "LINE2468=(ROWS/9)"
    let "LINE357=LINE2468"
    let "LINE9=LINE1+1"
 
    for (( x=0; x<=ROWS/16; x++))
    do
        for (( i=0; i<LINE1; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "LINE1++"
    
    
        for (( i=0; i<LINE2468; i++ ))
        do
            printf "_"
        done
        printf "1"
    
        for (( i=0; i<LINE357; i++ ))
        do
            printf "_"
        done
        printf "1"

        
        for (( i=0; i<LINE2468; i++ ))
        do
            printf "_"
        done
        printf "1"
        
        for (( i=0; i<LINE357; i++ ))
        do
            printf "_"
        done
        printf "1"
        
        for (( i=0; i<LINE2468; i++ ))
        do
            printf "_"
        done
        printf "1"

        for (( i=0; i<LINE357; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "LINE357++"
        let "LINE357++"


        for (( i=0; i<LINE2468; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "LINE2468--"
        let "LINE2468--"

    
        for (( i=0; i<LINE9; i++ ))
        do
            printf "_"
        done
        printf "\n"
        let "LINE9++"
    done

 
 
 
 
 
 
    
    
    
    
    let "LINE1=(COLUMNS/4)"
    let "LINE2=(ROWS/4)"
    let "LINE3=LINE2"
    let "LINE4=LINE2"
    let "LINE5=LINE1+1"

    #baseThree
    for (( x=0; x<=ROWS/16; x++))
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
        printf "1"

        for (( i=0; i<LINE4; i++ ))
        do
            printf "_"
        done
        printf "1"
    
        for (( i=0; i<LINE5; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done

fi



if [[ $LINE -gt 1 ]]
then
    
    let "LINE1=(COLUMNS/4)"
    let "LINE24=(ROWS/4)"
    let "LINE3=LINE24"
    let "LINE5=LINE1+1"

    if [[ $LINE -eq 2 ]]
    then
        #headerTwo
        for (( x=1; x<=(ROWS/4); x++))
        do
            for (( i=0; i<COLUMNS; i++ ))
            do
                printf "_"
            done
            printf "\n"
        done
    fi

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
    let "LINE2=LINE1-2"
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
let "LINE1=(COLUMNS/3)"
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
