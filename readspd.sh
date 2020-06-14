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

#if [ "$EUID" -ne 0 ]; then    #bashism

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

usage() { echo "Usage: $0 [-x]xmponly [-b <0-9>] [-d dimaddr <0x##>]" 1>&2; exit 1; }

main() {
    while getopts "b:d:x" o; do
        case "${o}" in
            b)
                BUS=${OPTARG}
                ;;
            d)
                DIMM=${OPTARG}
                ;; 
            x)
                XMP=1
                ;;
            *)
                usage
                ;;
        esac
    done
    shift "$((OPTIND-1))"
 
    if [ -z ${BUS} ] || [ -z ${DIMM} ]; then
        usage
    else
        readSPD ${DIMM}
    fi
    
    #removed to keep consistent script behavior between the python version and the bash version
    #if [ -n "$1" ]; then
    #    DIMM2=$1
    #    readSPD ${DIMM2}
    #fi

    #if [ -n "$2" ]; then 
    #    DIMM3=$2
    #    readSPD ${DIMM3}
    #fi

    #if [ -n "$3" ]; then
    #    DIMM4=$3
    #    readSPD ${DIMM4}
    #fi

}

#errcheck() { if [$? -ne 0]; then echo "Error, make sure i2c_dev and i2c_i801 modules are loaded. Check if you also have perms for current PWD" 1>&2; exit 1; }

readSPD() {
    i2cdump ${BUS} ${1} b
    
    if [ $? -ne 0 ]; then
        echo "Error, make sure i2c_dev and i2c_i801 modules are loaded."
        exit 1
    fi

    if [ -n "$XMP" ]; then
        EXT="xmp"
        INDEX=176
        END=250
    else
        EXT="spd"
        INDEX=0
        END=255
    fi

    DATE=$(date +%Y-%m-%d)
    echo "" | tr -d '\n' > dimm"${1}"."${DATE}".${EXT}
    
    if [ $? -ne 0 ]; then
        echo "Error writing file. Check file/folder permissions and try again."
        exit 1
    fi

    while [ ${INDEX} -le ${END} ]; do
        echo "Reading from SPD: $INDEX/$END"
        HEX=$(i2cget -y ${BUS} ${1} ${INDEX} | sed -ne 's/^0x\(.*\)/\1/p')
        echo "${HEX}"
        printf "\x${HEX}" >> dimm"${1}"."${DATE}".${EXT}
        INDEX=$((INDEX+1))
    done 
    
    echo ""
    echo "Dump written to: ${PWD}/dimm${1}.${DATE}.${EXT}"
   
    # contents of printf cant be saved to a bash variable, C-string ignores nullbytes 
    # and other special characters. The output must be sent to a file immediately.
    # alternatively, echo -e is not posix compliant so printf is the best way.     
}

main "$@"
