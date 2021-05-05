#!/bin/bash
set -e

cd "$(dirname "${0}")"

rm -rf orig
mkdir -p orig
for N in 0{1,2,3,4,5,6,7,8,9} {1,2,3,4,5,6,7,8,9,a}{0,1,2,3,4,5,6,7,8,9} b{1,2,3,4,5,6}; do
    F="st-${N}.lha"
    if [ ! -e "${F}" ]; then
        wget "http://aminet.net/mods/inst/${F}"
    fi
    lha -xw=orig "${F}" >/dev/null || true
done

# Delete samples larger than 8 KiB - to convert all samples, comment out the next line
find orig -type f -size +8192c -delete

find orig -type f -name '* *' -exec sh -c 'mv -v "{}" $(echo "{}" | sed "s/ /_/g") 2>/dev/null' \;

rm -rf wav uxn
for IN_DIR in orig/*; do
    echo "${IN_DIR}"
    OUT_DIR="$(basename "${IN_DIR}" | tr 'A-Z' 'a-z')"
    mkdir -p {wav,uxn}/{11025,22050}/"${OUT_DIR}"
    find "${IN_DIR}" -type f | while read f; do
        SAMPLE_RATE=
        if grep -q FORM "$f"; then
            if sox -t 8svx -b 8 -c 1 "$f" out.wav; then
                if file out.wav | grep -q ' [0-9][0-9][0-9][0-9][0-9] Hz$'; then
                    SAMPLE_RATE=22050
                else
                    SAMPLE_RATE=11025
                fi
            fi
        else
            sox -t raw -r 8363 -e signed -b 8 -c 1 "$f" out.wav
            SAMPLE_RATE=11025
        fi
        if [ -n "${SAMPLE_RATE}" ]; then
            OUT_FILE="${SAMPLE_RATE}/${OUT_DIR}/$(basename "$f")"
            sox out.wav -c 1 -b 8 -e unsigned-integer -r "${SAMPLE_RATE}" out.raw gain -4
            if [ "$(wc -c out.raw | cut -d ' ' -f 1)" -gt 256 ]; then
                mv out.wav "wav/${OUT_FILE}.wav"
                mv out.raw "uxn/${OUT_FILE}.pcm"
            fi
        fi
    done
done

du -hs orig uxn wav

