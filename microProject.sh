#!/bin/bash
RESULT_FILE="./Results.csv"
printf "NAME,EMAIL,GIT-URL,Git-Clone-Status,Build-status,Cppcheck,Valgrind
" > $RESULT_FILE


while IFS=, read -r NAME EMAIL REPO; do
    [[ $NAME != 'Name' ]] && printf "$NAME," >> $RESULT_FILE 
    [[ $EMAIL != 'Email ID' ]] && printf "$EMAIL," >> $RESULT_FILE
    if [ "$REPO" != 'Repo link' ]; then
        printf "$REPO," >> $RESULT_FILE
        git clone "$REPO"
        [[ $? == 0 ]] && printf "Clone Success," >> $RESULT_FILE
        [[ $? > 0 ]] && printf "Clone failed," >> $RESULT_FILE
        REPO=`echo "$REPO" | cut -d'/' -f5`
        echo "REPO = $REPO"
        DIR=`find "$REPO" -name "Makefile" -exec dirname {} \;`
        make -C "$DIR"
        [[ $? == 0 ]] && printf "build Success," >> $RESULT_FILE
        [[ $? > 0 ]] && printf "build failed," >> $RESULT_FILE
        ERRORS=`cppcheck "$DIR" | grep 'error' | wc -l`
        printf "$ERRORS," >> $RESULT_FILE
        make test -C "$DIR"
        EXECUTABLE=`find "$DIR" -name "Test*.out"`
        echo "$EXECUTABLE"
        valgrind "./$EXECUTABLE" 2> valgrinderr.csv
        VALGRINDERR=`grep "ERROR SUMMARY" valgrinderr.csv`
        printf "${VALGRINDERR:24:1} \n" >> $RESULT_FILE
        
    fi
done < Input.csv