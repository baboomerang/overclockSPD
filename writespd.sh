#!/bin/bash

# Project: readspd - a RAM SPD reading tool similar to TB2BIN
# Author: baboomerang https://github.com/baboomerang/
# Date: 02/15/2020

# WRITESPD.sh ========================================================
# Make sure i2c_dev, i2c_i801, i2c_algo_bit are loaded.
# This should write to the spd of the ram from a file (255 bytes) long.
# For saftey reasons this writes to only one spd at a time.

#<<COMMENT
#DISCLAIMER: This "writespd" script is provided by baboomerang (the writer & provider of this software)\
#"as is" and "with all faults."baboomerang (the writer & provider of this software)\
#makes no representations or warranties of any kind concerning the safety,\
#suitability, lack of viruses, inaccuracies, typographical errors, or other harmful\
#components of this "writespd" script. There are inherent dangers in the use of any software,\
#and you are solely responsible for determining whether this "writespd" script is compatible \
#with your equipment and other software installed on your equipment. You are also solely \
#responsible for the protection of your equipment and backup of your data, and\
#baboomerang (the writer & provider of this software) will not be liable for any damages\
#you may suffer in connection with using, modifying, or distributing this "writespd" script.
#COMMENT


usage() {
    echo "Usage: $0 [-x]XMP ONLY [-b] I2C BUS ADDRESS [-d] DIMM ADDRESS [FILENAME]" 1>&2;
    echo "I2C BUS ADDRESS is an integer (usually 0-9)" 1>&2;
    echo "DIMM ADDRESS is an integer (usually 0x50 through 0x54 for DDR3 systems)" 1>&2;
    echo "Example: $0 -b 6 -d 0x50 sampledump.spd" 1>&2;
    exit 1;
}

main() {
    # Script must be ran as root user
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi

    # Get and parse commandline options
    while getopts "b:d:x" o; do
        case "${o}" in
            b)  BUS=${OPTARG};;
            d)  DIM=${OPTARG};;
            x)  XMP_MODE=1;;
            *)  usage;;
        esac
    done

    if [ -z "$BUS" ] || [ -z "$DIMM" ] || [ -z "$INPUTFILE" ]; then
        usage
    fi

    # Shift out all parameters except the last one (the input file)
    shift "$((OPTIND-1))"

    INPUTFILE=$1

    echo "WARNING! Do not write an incorrect or bad address for i2cbus or dimm!"
    echo "Writing to non-dimm locations can cause permanent damage!"
    echo "Please have backups incase something goes wrong."
    sleep 1

    # Show preview of the target device over i2c (in bytes)
    if [ $(i2cdump -y "$BUS" "$DIMM" b) ]; then
        echo "Error, make sure i2c_dev and i2c_i801 modules are loaded."
        exit 1
    fi
    echo "Preview of target device: is this the intended device?"
    sleep 1

    # Prompt user again as an extra safety precaution
    read -p "Knowing these risks, you will write to bus $BUS address $DIMM. Proceed? [yes/No]: " yn
    case $yn in
        yes ) write_spd;;
        no ) exit 0;;
        * ) echo "Error: response must be exactly \"yes\" or \"no\""; exit 1;;
    esac

    exit 0
}

write_spd() {
    # Check if the file is actually a file and not a directory or something else
    if [ ! -f "$INPUTFILE" ]; then
        echo "Cannot find file. Double check permissions or location and try again."
        exit 1
    fi

    # I used this instead of IFS
    local rawhex=$(cat "$INPUTFILE" | xxd -p -c 256 | tr -d '\n'| sed -e 's/../0x& /g')
    local arrayhex=($rawhex)
    local filelength=${#arrayhex[@]}

    # File Extension, Byte offset into SPD region, Byte End
    local ext=""
    local offset=0
    local end=0

    if [ -n "$XMP_MODE" ]; then
        if [ "$filelength" != 40 ]; then
            echo "XMP file must be exactly 40 bytes"
            exit 1
        fi
        ext="xmp"
        offset=176
        end=219     #XMP Profile 2 starts at the 221st byte (index 220)
    else
        if [ "$filelength" != 256 ]; then
            echo "SPD file must be exactly 256 bytes"
            exit 1
        fi
        ext="spd"
        offset=0
        end=255
    fi

    local index=0
    while [ $((index+offset)) -le ${end} ]; do
        echo "Writing to SPD: $((index+offset))/$end BYTE:(${arrayhex[${index}]})"
        sleep 0.2
        i2cset -y "$BUS" "$DIMM" $((index+offset)) "${arrayhex[${index}]}"
        index=$((index+1))
    done

    echo "\n$INPUTFILE written successfully to $DIMM"
}

main "$@"
