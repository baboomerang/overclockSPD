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

__error_i2c="
Error: i2cget failed. Your i2c device may be in an unknown state.
Double check to see if any data was changed or lost.
"

__error_printf="
Error: printf failed. Check if you have write permissions to the file
OR if printf is installed on your system.
"

__usage="
Usage: $(basename $0) [OPTIONS]

Options:
  -x,                 Read XMP profile only
  -b, <address>       Which i2c bus should be used (in decimal)
                      usually this is an integer (0-9)

  -d, <address>       Which specific device should be read from (in hex)
                      for DDR3 systems, usually (0x50, 0x51, 0x52, 0x53)
                      0x50 - first dimm slot
                      0x51 - second dimm slot
                      0x52 - third dimm slot
                      0x53 - fourth dimm slot

  -h,                 Show this usage section

Example:
  $(basename $0) -b 6 -d 0x50
  $(basename $0) -b 6 -d 0x50 -x
"

usage() {
    echo "$__usage"
}

main() {
    # Script must be ran as root user
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi

    # Get and parse commandline options
    while getopts "b:d:xh" opt; do
        case "${opt}" in
            b)  BUS=${OPTARG};;
            d)  DIMM=${OPTARG};;
            x)  XMP_MODE=1;;
            h)  usage
                exit 0;;
            *)  usage
                exit 1;;
        esac
    done

    # Script can only work with valid BUS and DIMM numbers
    if [ -z "$BUS" ] || [ -z "$DIMM" ]; then
        usage
        exit 1
    fi

    read_spd

    exit 0
}

read_spd() {
    # Print SPD contents to terminal in bytes
    i2cdump -y "$BUS" "$DIMM" b

    if [ $? -ne 0 ]; then
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
    local filename="dimm"$DIMM"."$date".$ext"
    echo -n "" > "$filename"

    if [ $? -ne 0 ]; then
        echo "Error writing file. Check file/folder permissions and try again."
        exit 1
    fi

    while [ ${index} -le ${end} ]; do
        echo "Reading from SPD: $index/$end"
        local hex=$(i2cget -y "$BUS" "$DIMM" ${index} | sed -ne 's/^0x\(.*\)/\1/p')

        # If i2cget failed during the read, something weird happened in the machine
        if [ $? -ne 0 ]; then
            echo "$__error_i2c"
            exit 1
        fi

        echo "${hex}"
        printf "\x${hex}" >> "$filename"

        # If printf failed, then either you do not have permissions to write to the file
        # OR somehow printf is not present on this machine
        if [ $? -ne 0 ]; then
            echo "$__error_printf"
            exit 1
        fi

        index=$((index+1))
    done

    echo "Dump written to: ${PWD}/${filename}"
}

main "$@"
