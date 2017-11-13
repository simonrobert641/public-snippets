#!/usr/bin/env bash

cookiesFile=/tmp/bashTests.cookies
OUT=/tmp/bashTests.out
R=0
DEBUG=0

# Commande curl
_myCurl="curl -v -k -L -c $cookiesFile -b $cookiesFile"

rm -f "$cookiesFile"

function GET {
    url="$1"
    shift
    echo -n "GET $url :"
    $_myCurl "$url" "$@" &> "$OUT" &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; cp -v "$OUT" "$OUT.$(date +%Y-%m-%d_%H-%M-%S)"; false; }
}

function POST {
    url="$1"
    echo -n "POST $url :"
    local i=0 args=()
    while read line; do
        args[$i]="--data-urlencode"
        ((++i))
        args[$i]="$line"
        ((++i))
    done < <(cat)

    test "$DEBUG" -eq 0 || set -x

    shift
    $_myCurl "$url" -X POST "${args[@]}" "$@" &> "$OUT"
    local r=$?
    test "$DEBUG" -eq 0 || set +x;
    test "$r" -eq 0 &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; cp -v "$OUT" "$OUT.$(date +%Y-%m-%d_%H-%M-%S)"; false; }
}

function RAWPOST {
    url="$1"
    shift
    echo -n "POST $url :"
    test "$DEBUG" -eq 0 || set -x
    $_myCurl "$url" -X POST "${args[@]}" "$@" --data-binary - &> "$OUT"
    local r=$?
    test "$DEBUG" -eq 0 || set +x;
    test "$r" -eq 0 &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; cp -v "$OUT" "$OUT.$(date +%Y-%m-%d_%H-%M-%S)"; false; }
}

function GREP {
    echo -n "GREP $* :"
    egrep "$*" "$OUT" &> /dev/null &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; cp -v "$OUT" "$OUT.$(date +%Y-%m-%d_%H-%M-%S)"; false; }
}

function NOGREP {
    echo -n "NOGREP $* :"
    egrep "$*" "$OUT" &> /dev/null
    test "$?" -ne 0 &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; cp -v "$OUT" "$OUT.$(date +%Y-%m-%d_%H-%M-%S)"; false; }
}

function SHELL {
    echo -n "SHELL $* :"
    "$@" > "$OUT" &&
    { echo -e "\e[0;49;92m OK \e[0m"; true; } ||
    { echo -e " \e[7;49;91m FAIL \e[0m"; R=1; cp -v "$OUT" "$OUT.$(date +%Y-%m-%d_%H-%M-%S)"; false; }
}

function EXTRACT {
    re="$1"
    subs="$2"
    test "$subs" = "" && subs='$1'
    cat "$OUT" | perl -n0e "\$i=\$_; s|^.*?$re.*$|$subs|s; print if \$i =~ m|$re|s"
}

function END {
    test "$R" -eq 0 &&
    { echo -e "\e[7;49;92m SUCCESS \e[0m"; true; } ||
    { echo -e "\e[7;49;91m FAILURE \e[0m"; false; }
}

