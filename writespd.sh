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

__error_i2c="
Error: i2cset failed. Cannot write SPD. The SPD EEPROM might be locked.
If locked EEPROM, try writing XMP profile instead.

If XMP also fails, then the EEPROM might be fully locked.
"

__usage="
Usage: $(basename $0) [OPTIONS]

Options:
  -x,                 Write XMP profile only
  -b, <address>       Which i2c bus should be used (in decimal)
                      usually this is an integer (0-9)

  -d, <address>       Which specific device should be written to (in hex)
                      for DDR3 systems, usually (0x50, 0x51, 0x52, 0x53)
                      0x50 - first dimm slot
                      0x51 - second dimm slot
                      0x52 - third dimm slot
                      0x53 - fourth dimm slot

  -h,                 Show this usage section

Example:
  $(basename $0) -b 6 -d 0x50 sampledump.spd
  $(basename $0) -b 6 -d 0x50 -x 2400cl12.xmp
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
    local OPTIND=1
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

    # Shift out all parameters except the last one (the input file)
    shift "$((OPTIND-1))"

    INPUTFILE=$1

    if [ -z "$BUS" ] || [ -z "$DIMM" ] || [ -z "$INPUTFILE" ]; then
        usage
        exit 1
    fi

    # Warn user of the possible risks using this script
    echo "WARNING! Do not write an incorrect or bad address for i2cbus or dimm!"
    echo "Writing to non-dimm locations can cause permanent damage!"
    echo "Please have backups incase something goes wrong."
    sleep 1

    # Show preview of the target device over i2c (in bytes)
    i2cdump -y "$BUS" "$DIMM" b

    if [ $? -ne 0 ]; then
        echo "Error, make sure i2c_dev and i2c_i801 modules are loaded."
        exit 1
    fi

    # If the command was successful, ask the user if this is the intended device
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
    local rawhex=$(xxd -p -c 256 "$INPUTFILE" | tr -d '\n' | sed -e 's/../0x& /g')
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
        offset=0;
        end=255
    fi

    local index=0
    while [ $((index+offset)) -le ${end} ]; do
        echo "Writing to SPD: $((index+offset))/$end BYTE:(${arrayhex[${index}]})"
        sleep 0.2

        i2cset -y "$BUS" "$DIMM" $((index+offset)) "${arrayhex[${index}]}"

        # If i2cset failed during the flash, the EEPROM might be locked
        if [ $? -ne 0 ]; then
            echo "$__error_i2c"
            exit 1;
        fi

        index=$((index+1))
    done

    echo "$INPUTFILE written successfully to $DIMM"
}

main "$@"
