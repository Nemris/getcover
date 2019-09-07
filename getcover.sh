#!/bin/bash

checkdeps() {
    local deps
    # on windows git bash must download:
    # CRC32: http://esrg.sourceforge.net/utils_win_up/md5sum/crc32.exe to "C:\Program Files\Git\usr\bin"
    # WGET: https://gist.github.com/evanwill/0207876c3243bbb6863e65ec5dc3f058
    deps="awk wget xxd crc32 sed"
    unameOut="$(uname -s)"
    case "${unameOut}" in
    CYGWIN* | MINGW*)
        OS=Windows
        ;;
    esac

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

    if [ "$romtype" = "nds" ]; then
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
    else
        # baseurl="http://hakchicloud.com/Hakchi_Themes/dsart"
        baseurl="https://github.com/DefKorns/rom-cover-generator/raw/master/boxart/"
        getcover "$baseurl/$tid.png"
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
    if [ "$romtype" = "nds" ]; then
        wget -q -nc --compression=auto "$1"
    else
        if [ $romtype = "md" ]; then
            romtype="gen"
        fi
        wget -q -nc --compression=auto "$1" -O "$title.$romtype.png"
    fi
}

rename() {
    if [ -f "$1" ]; then
        mv "$1" "$2"
    fi
}

help() {
    echo ""
    echo "Usage:
   ./$(basename "$0") titleID | ndsfile [titleID] | ndsfile | files | [options]..."
    echo ""
    echo "Files:
   Rom files of type: \"*.nes\", \"*.snes\", \"*.gb\", \"*.gbc\", \"*.sms\", \"*.gen\", \"*.gg\""
    echo ""
    echo "Options:
   -?, -h, -help	      This information screen
   game_name.nds              Downloads boxart for a expecific NDS game
   titleID                    Same as above
   *.*                        Downloads boxart to all roms on the directory
   *.(extension)              Downloads boxart for supported roms on the directory"
    echo ""
    echo "Examples:
   ./$(basename "$0") *.nds                Downloads boxart for all NDS games
   ./$(basename "$0") Mario Bros.nds       Downloads boxart by game title
   ./$(basename "$0") AMCE                 Download boxart by titleID (this case \"Mario Kart DS\")
   ./$(basename "$0") *.nes                Downloads boxart for NES roms on the directory
   ./$(basename "$0") *.snes               Downloads boxart for SNES roms on the directory
   ./$(basename "$0") *.md                 Downloads boxart for Mega Drive and also converts the roms to *.gen
   ./$(basename "$0") -?                   Display help info"
    echo ""
    exit 1
}

checkdeps

if [ $# -lt 1 ]; then
    help
fi

for i in "$@"; do
    case $i in
    *.nds)
        romtype="nds"
        tid=$(gettid "$i")

        if [ -z "$tid" ]; then
            echo "$i: not a .nds file"
            continue
        fi
        ;;
    *.nes | *.gbc | *.snes | *.gb | *.sms | *.gen | *.gg | *.md)
        fulltitle=$(basename -- "$i")
        romtype="${fulltitle##*.}"
        title="${fulltitle%.*}"

        if [[ "$i" == *.md ]]; then
            rename "$i" "$title.gen"
            i="$title.gen"
        fi

        tid=$(crc32 "$i")
        if [ $OS = "Windows" ]; then
            tid=$(crc32 "$i" | sed -e 's/^0x\(.\{8\}\).*/\1/')
        fi
        ;;
    *.*)
        romfamily=(*.nes *.gbc *.snes *.gb *.sms *.gen *.gg *.md)
        for ext in "${romfamily[@]}"; do
            i="$ext"
        done
        ;;
    '-?' | -h | -help)
        help
        ;;
    esac

    searchcover "$tid"
done
