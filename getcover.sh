#!/bin/bash

BOXART_URL="https://art.gametdb.com/ds/coverS"
TITLEID_SIZE=4

# Fetch the boxart matching a game ID.
# Globals:
#   BOXART_URL
# Arguments:
#   Title ID whose boxart to fetch.
# Outputs:
#   The downloaded boxart in $PWD.
# Returns:
#   0 if the download succeeded, nonzero otherwise.
function fetch_cover() {
    local langs=(EN US JA DE FR KO)

    for lang in "${langs[@]}"; do
        wget -nc --compression=auto "${BOXART_URL}/${lang}/$1.png" && break
    done

    # This will be nonzero if no attempts succeeded.
    return $?
}

# Get the title ID from an .nds file.
# Globals:
#   TITLEID_SIZE
# Arguments:
#   An .nds file.
# Outputs:
#   The extracted title ID if valid, else nothing.
# Returns:
#   0 if the title ID could be extracted, nonzero otherwise.
function get_tid() {
    local tid

    tid="$(tail -c +13 "$1" | head -c ${TITLEID_SIZE})" || return $?
    is_tid_valid "${tid}" || return 1

    echo "${tid}"
}

# Determine if a string is a valid title ID.
# Globals:
#   TITLEID_SIZE
# Arguments:
#   A string.
# Returns:
#   0 if the title ID is valid, nonzero otherwise.
function is_tid_valid() {
    [[ "${#1}" -ne ${TITLEID_SIZE} || "$1" == *[![:ascii:]]* ]] && return 1
    return 0
}

# Entrypoint.
# Arguments:
#   One or more titleIDs and/or .nds files.
function main() {
    local tid

    for arg in "$@"; do
        if [[ "${arg}" == *.nds ]]; then
            if ! tid=$(get_tid "${arg}"); then
                echo "'${arg}': could not extract title ID, skipping..." >&2
                continue
            fi
        else
            if ! is_tid_valid "${arg}"; then
                echo "'${arg}': invalid title ID, skipping..." >&2
                continue
            fi
            tid="${arg@U}"
        fi

        fetch_cover "${tid}" || echo "'${tid}': cover download failed" >&2
    done
}

if ! hash wget 2>/dev/null; then
    echo "Fatal: dependency 'wget' not found. Aborting." >&2
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $(basename "$0") titleid | ndsfile [titleid | ndsfile ...]"
    exit 1
fi

main "$@"
