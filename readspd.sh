#!/bin/bash

# Project: readspd - a RAM SPD reading tool similar to TB2BIN
# Author: baboomerang https://github.com/baboomerang/
# Date: 02/15/2020

# READSPD.sh ===============================================================
# Make sure i2c_dev, i2c_i801, i2c_algo_bit are loaded.
# This should read the spd data of the RAM (255 bytes) and write it to a file named
# dimm{hex-address}.spd in the current PWD

#<<COMMENT
#DISCLAIMER: This "readspd" script is provided by baboomerang (the writer & provider of this software)\
#"as is" and "with all faults." baboomerang (the writer & provider of this software)\
#makes no representations or warranties of any kind concerning the safety,\
#suitability, lack of viruses, inaccuracies, typographical errors, or other harmful\
#components of this "readspd" script. There are inherent dangers in the use of any software,\
#and you are solely responsible for determining whether this "readspd" script is compatible \
#with your equipment and other software installed on your equipment. You are also solely \
#responsible for the protection of your equipment and backup of your data, and\
#baboomerang (the writer & provider of this software) will not be liable for any damages\
#you may suffer in connection with using, modifying, or distributing this "readspd" script.
#COMMENT

usage() {
    echo "Usage: $0 [-x]XMP ONLY [-b] I2C BUS ADDRESS [-d] DIMM ADDRESS" 1>&2;
    echo "I2C BUS ADDRESS is an integer (usually 0-9)" 1>&2;
    echo "DIMM ADDRESS is an integer (usually 0x50 through 0x54 for DDR3 systems)" 1>%2;
    echo "Example: $0 -b 6 -d 0x50" 1>&2;
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
            d)  DIMM=${OPTARG};;
            x)  XMP_MODE=1;;
            *)  usage;;
        esac
    done

    # Shift out all parameters except the last one (the input file)
    shift "$((OPTIND-1))"

    # Script can only work with valid BUS and DIMM numbers
    if [ -z "$BUS" ] || [ -z "$DIMM" ]; then
        usage
    fi

    readSPD

    exit 0
}

readSPD() {
    # Print SPD contents to terminal in bytes
    if [ $(i2cdump "$BUS" "$DIMM" b) ]; then
        echo "Error, make sure i2c_dev and i2c_i801 modules are loaded."
        exit 1
    fi

    # File Extension, Byte offset into SPD region, Byte End
    local ext=""
    local index=0
    local end=0

    if [ -n "$XMP_MODE" ]; then
        ext="xmp"
        index=176
        end=250
    else
        ext="spd"
        index=0
        end=255
    fi

    local date=$(date +%Y-%m-%d)
    echo "" | tr -d '\n' > dimm"$DIMM"."$date".$ext

    if [ $? -ne 0 ]; then
        echo "Error writing file. Check file/folder permissions and try again."
        exit 1
    fi

    while [ ${index} -le ${end} ]; do
        echo "Reading from SPD: $index/$end"
        local hex=$(i2cget -y "$BUS" "$DIMM" ${index} | sed -ne 's/^0x\(.*\)/\1/p')
        echo "${hex}"
        printf "\x${hex}" >> dimm"$DIMM"."$date".$ext
        index=$((index+1))
    done

    echo "\nDump written to: ${PWD}/dimm$DIMM.$date.$ext"
}

main "$@"
