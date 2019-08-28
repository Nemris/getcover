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
    echo "Searching for $1..."

    if wget --spider "$baseurl/$lid/$1.png" 2>&1 | grep -q '404'; then
        for i in "${langs[@]}"; do
            lid="$i"
            getcover "$baseurl/$lid/$1.png"
        done
    fi

    getcover "$baseurl/$lid/$1.png"
}

gettid() {
    if [ -f "$1" ]; then
        xxd -s 12 -l 4 "$1" | awk '{print $4}'
    fi
}

getcover() {
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
