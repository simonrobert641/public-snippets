#!/usr/bin/env bash

cookiesFile=/tmp/curlTests.cookies
OUT=/tmp/curlTests.out
R=0
DEBUG=0

# Commande curl
_myCurl="curl -v -L -c $cookiesFile -b $cookiesFile"

rm -f "$cookiesFile"

function GET {
    echo -n "GET $1 :"
    $_myCurl "$*" &> "$OUT" &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; false; }
}

function POST {
    echo -n "POST $1 :"
    local i=0 args=()
    while read line; do
        args[$i]="--data-urlencode"
        ((++i))
        args[$i]="$line"
        ((++i))
    done < <(cat)

    test "$DEBUG" -eq 0 || set -x
    $_myCurl "$1" -X POST "${args[@]}" &> "$OUT"
    local r=$?
    test "$DEBUG" -eq 0 || set +x;
    test "$r" -eq 0 &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; false; }
}

function GREP {
    echo -n "GREP $* :"
    egrep "$*" "$OUT" &> /dev/null &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; false; }
}

function NOGREP {
    echo -n "NOGREP $* :"
    egrep "$*" "$OUT" &> /dev/null
    test "$?" -ne 0 &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; false; }
}

function EXTRACT {
    cat "$OUT" | perl -p0e "s|^.+?$1.+$|$2|s"
}

function END {
    test "$R" -eq 0 &&
    { echo -e "\e[7;49;92m SUCCESS \e[0m"; true; } ||
    { echo -e "\e[7;49;91m FAILURE \e[0m"; false; }
}

