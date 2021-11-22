#!/bin/bash
#@bugsam 11/21/2021

ROWS=63
COLUMNS=100

read LINE

if [[ $LINE -eq 5 ]]
then
    if [[ $LINE -eq 5 ]]
    then
        #headerFour
        let "H5=(ROWS/32)"
        for (( x=1; x<=H5; x++))
        do
            for (( i=0; i<COLUMNS; i++ ))
            do
                printf "_"
            done
            printf "\n"
        done
    fi
    
    #Five
    let "R5=(ROWS/64)"
    let "COL1=(COLUMNS/7)+4"
    let "COL2468ACE10=(ROWS/32)"
    let "COL3579BDF=COL2468ACE10"
    let "COL11=COL1+1"
    
    for (( x=0; x<=R5; x++))
    do
        for (( i=0; i<COL1; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "COL1++"
    
        for (( y=0; y<=14; y++ ))
        do
            for (( i=0; i<COL2468ACE10; i++ ))
            do
                printf "_"
            done
            printf "1"
        
            for (( i=0; i<COL3579BDF; i++ ))
            do
                printf "_"
            done
            printf "1"
        done

        for (( i=0; i<COL2468ACE10; i++ ))
        do
            printf "_"
        done
        printf "1"

        let "COL2468ACE10--"
        let "COL2468ACE10--"

        let "COL3579BDF++"
        let "COL3579BDF++"

        for (( i=0; i<COL11; i++ ))
        do
            printf "_"
        done
        printf "\n"
        let "COL11++"
    done
    

    #baseFive
    let "COL1=(COLUMNS/6)+3"
    let "COL2468ACE10=(ROWS/16)"
    let "COL3579BDF=COL2468ACE10"
    let "COL11=COL1+1"

    for (( x=0; x<=R5; x++))
    do
        for (( i=0; i<COL1; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "COL1++"
    
        for (( y=0; y<=6; y++ ))
        do
            for (( i=0; i<COL2468ACE10; i++ ))
            do
                printf "_"
            done
            printf "1"
        
            for (( i=0; i<COL3579BDF; i++ ))
            do
                printf "_"
            done
            printf "1"
        done

        for (( i=0; i<COL2468ACE10; i++ ))
        do
            printf "_"
        done
        printf "1"

        let "COL2468ACE10--"
        let "COL2468ACE10--"

        let "COL3579BDF++"
        let "COL3579BDF++"

        for (( i=0; i<COL11; i++ ))
        do
            printf "_"
        done
        printf "\n"
        let "COL11++"
    done
fi



if [[ $LINE -gt 3 ]]
then
    if [[ $LINE -eq 4 ]]
    then
        #headerFour
        let "H4=(ROWS/16)"
        for (( x=1; x<=H4; x++))
        do
            for (( i=0; i<COLUMNS; i++ ))
            do
                printf "_"
            done
            printf "\n"
        done
    fi
    
    #Four
    let "R4=(ROWS/32)"
    let "COL1=(COLUMNS/6)+3"
    let "COL2468ACE10=(ROWS/16)"
    let "COL3579BDF=COL2468ACE10"
    let "COL11=COL1+1"

    for (( x=0; x<=R4; x++))
    do
        for (( i=0; i<COL1; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "COL1++"
    
        for (( y=0; y<=6; y++ ))
        do
            for (( i=0; i<COL2468ACE10; i++ ))
            do
                printf "_"
            done
            printf "1"
        
            for (( i=0; i<COL3579BDF; i++ ))
            do
                printf "_"
            done
            printf "1"
        done

        for (( i=0; i<COL2468ACE10; i++ ))
        do
            printf "_"
        done
        printf "1"

        let "COL2468ACE10--"
        let "COL2468ACE10--"

        let "COL3579BDF++"
        let "COL3579BDF++"

        for (( i=0; i<COL11; i++ ))
        do
            printf "_"
        done
        printf "\n"
        let "COL11++"
    done

    let "COL1=(COLUMNS/5)+1"
    let "COL2468=(ROWS/8)"
    let "COL357=COL2468"
    let "COL9=COL1+1"

    #baseFour
    for (( x=0; x<=R4; x++))
    do
        for (( i=0; i<COL1; i++ ))
        do
            printf "_"
        done
        printf "1"
    
        for (( y=0; y<=2; y++ ))
        do
            for (( i=0; i<COL2468; i++ ))
            do
                printf "_"
            done
            printf "1"
        
            for (( i=0; i<COL357; i++ ))
            do
                printf "_"
            done
            printf "1"
        done
        for (( i=0; i<COL2468; i++ ))
        do
            printf "_"
        done
        printf "1"
    
        for (( i=0; i<COL9; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done
fi

if [[ $LINE -gt 2 ]]
then
    if [[ $LINE -eq 3 ]]
    then
        #headerThree
        let "H3=(ROWS/8)"
        for (( x=1; x<=H3; x++))
        do
            for (( i=0; i<COLUMNS; i++ ))
            do
                printf "_"
            done
            printf "\n"
        done
    fi
    
    #Three
    let "R3=(ROWS/16)"
    let "COL1=(COLUMNS/5)+1"    #ROWS/3
    let "COL2468=(ROWS/8)"
    let "COL357=COL2468"
    let "COL9=COL1+1"
 
    for (( x=0; x<=R3; x++))
    do
        for (( i=0; i<COL1; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "COL1++"
    
        for (( y=0; y<=2; y++ ))
        do
            for (( i=0; i<COL2468; i++ ))
            do
                printf "_"
            done
            printf "1"
        
            for (( i=0; i<COL357; i++ ))
            do
                printf "_"
            done
            printf "1"
        done
        
        for (( i=0; i<COL2468; i++ ))
        do
            printf "_"
        done
            printf "1"

        let "COL2468--"
        let "COL2468--"

        let "COL357++"
        let "COL357++"

    
        for (( i=0; i<COL9; i++ ))
        do
            printf "_"
        done
        printf "\n"
        let "COL9++"
    done

    let "COL1=(COLUMNS/4)"
    let "COL234=(ROWS/4)"
    let "COL5=COL1+1"

    #baseThree
    for (( x=0; x<=R3; x++))
    do
        for (( i=0; i<COL1; i++ ))
        do
            printf "_"
        done
        printf "1"
        
        for (( y=0; y<=2; y++ ))
        do
            for (( i=0; i<COL234; i++ ))
            do
                printf "_"
            done
            printf "1"
        done
        
        for (( i=0; i<COL5; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done

fi



if [[ $LINE -gt 1 ]]
then
    if [[ $LINE -eq 2 ]]
    then
        #headerTwo
        let "H2=(ROWS/4)"
        for (( x=1; x<=H2; x++))
        do
            for (( i=0; i<COLUMNS; i++ ))
            do
                printf "_"
            done
            printf "\n"
        done
    fi

    #Two
    let "R2=ROWS/8"
    let "COL1=(COLUMNS/4)"
    let "COL24=(ROWS/4)"
    let "COL3=COL24"
    let "COL5=COL1+1"
    
    for (( x=0; x<=R2; x++))
    do
        for (( i=0; i<COL1; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "COL1++"
    
    
        for (( i=0; i<COL24; i++ ))
        do
            printf "_"
        done
        printf "1"
    
        for (( i=0; i<COL3; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "COL3++"
        let "COL3++"
        
        for (( i=0; i<COL24; i++ ))
        do
            printf "_"
        done
        printf "1"
        let "COL24--"
        let "COL24--"
    
        for (( i=0; i<COL5; i++ ))
        do
            printf "_"
        done
        printf "\n"
        let "COL5++"
    done
    
    let "COL1=(COLUMNS/3)"
    let "COL2=(ROWS/2)"
    let "COL3=COL1+1"

    #baseTwo
    for (( x=0; x<=R2; x++))
    do
        for (( i=0; i<COL1; i++ ))
        do
            printf "_"
        done
        printf "1"
        
        for (( i=0; i<COL2; i++ ))
        do
            printf "_"
        done
        printf "1"
    
        for (( i=0; i<COL3; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done
fi


if [[ $LINE -eq 1 ]]
then
    #headerOne
    let "H1=(ROWS/2)"
    for (( x=1; x<=H1; x++))
    do
        for (( i=0; i<COLUMNS; i++ ))
        do
            printf "_"
        done
        printf "\n"
    done
fi


#One
let "R1=(ROWS/4)"
let "COL1=(COLUMNS/3)"
let "COL2=(ROWS/2)"
let "COL3=COL1+1"

for (( x=0; x<=R1; x++))
do
    for (( i=0; i<COL1; i++ ))
    do
        printf "_"
    done
    printf "1"
    let "COL1++"
    
    for (( i=0; i<COL2; i++ ))
    do
        printf "_"
    done
    printf "1"
    let "COL2--"
    let "COL2--"

    for (( i=0; i<COL3; i++ ))
    do
        printf "_"
    done
    printf "\n"
    let "COL3++"
done

#baseOne
let "COL1=(COLUMNS/2)-1"
let "COL2=COL1+1"

for (( x=0; x<=R1; x++))
do
    for (( i=0; i<COL1; i++ ))
    do
        printf "_"
    done
        printf "1"
    for (( i=0; i<COL2; i++ ))
    do
        printf "_"
    done
    if [[ $x -lt $R1 ]]
    then
        printf "\n"
    fi
done
