#!/bin/bash

checkdeps() {
    local deps
    deps="awk wget xxd"

    for dep in $deps; do
        if [ -z "$(command -v "$dep")" ]; then
            echo "Fatal: the required dependency \"$dep\" is missing."
            exit 1
        fi
    done
}

searchcover() {
    local baseurl
    local lid
    local langs
    baseurl="https://art.gametdb.com/ds/coverS"
    lid="EN"
    langs=(US JA DE FR KO)

    if ! getcover "$baseurl/$lid/$1.png"; then
        for i in "${langs[@]}"; do
            lid="$i"
            getcover "$baseurl/$lid/$1.png"
            status=$?
            # exits for loop on first success preventing failed message per array language
            if [ "${status:-0}" -eq 0 ]; then 
                break
            fi
        done
    fi

    # file not found or no connection available
    # "${status:-0}" fix [: -ne: unary operator expected and [: : integer expression expected
    if [ "${status:-0}" -ne 0 ]; then 
        echo "$1: cover download failed." 1>&2
    fi
}

gettid() {
    if [ -f "$1" ]; then
        xxd -s 12 -l 4 "$1" | awk '{print $4}'
    fi
}

getcover() {
    # '-nc' ||'--no-clobber', overwrites the file instead of creating multiple files if they already exits
    wget -q -nc --compression=auto "$1"
}

checkdeps

if [ $# -lt 1 ]; then
    echo "Usage: $(basename "$0") titleID | ndsfile [titleID | ndsfile ...]"
    exit 1
fi

for i in "$@"; do
    if [[ "$i" == *.nds ]]; then
        tid=$(gettid "$i")

        if [ -z "$tid" ]; then
            echo "$i: not a .nds file"
            continue
        fi
    else
        tid="$(echo "$i" | awk '{print toupper($0)}')"
    fi

    searchcover "$tid"
done
