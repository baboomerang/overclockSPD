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

if [ "$EUID" -ne 0 ];
    then echo "Please run as root"
    exit
fi

usage() { echo "Usage: $0 [-b busaddr#] [-d dimaddr <0x##>] [-x(mp) mode] [FILE]" 1>&2; exit 1; }

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

    INPUTFILE=$1

    if [ -z "${BUS}" ] || [ -z "${DIMM}" ] || [ -z "${INPUTFILE}" ]; then
        usage
    else                                                                                                                          
        echo "WARNING! Do not write incorrect or bad address for bus/dimm!"
        echo "Writing to non-dimm locations can cause damage!"
        echo "Please have backups incase something goes wrong."
        sleep 1
     
        i2cdump -y ${BUS} ${DIMM} b
        echo "Preview of target device: is this the device?" 
        sleep 1
    
        read -p "Knowing these risks, you will write to bus ${BUS} address ${DIMM}. Proceed? [yesiwanttoproceedknowingtheserisks/no]: " yn
        case $yn in
            yes ) writeSPD DIMM;;
            #            yesiwanttoproceedknowingtheserisks ) writeSPD DIMM;;
            no ) exit 1;;
            * ) echo "Error: response must be exact option, verbatim as given."; exit 1;;
        esac
    fi

}

writeSPD() {
    if [ ! -f $INPUTFILE ]; then
        echo "Cannot find file. Double check permissions or location and try again."
        exit 1
    fi

    #these 3 lines may not be posix compliant
    RAWHEX=$(cat ${INPUTFILE} | xxd -p -c 256 | tr -d '\n'| sed -e 's/../0x& /g')
    ARRAYHEX=($RAWHEX)
    FILELENGTH=${#ARRAYHEX[@]}

    if [ -n "${XMP}" ]; then
        if [ ${FILELENGTH} != 40 ]; then
            echo "XMP file must be exactly 40 bytes"
            exit 1
        fi
        EXT="xmp"
        OFFSET=176
        END=216
        #END=250 #this may erase profile 2 if you have anything there.
    else
        if [ ${FILELENGTH} != 256 ]; then
            echo "SPD file must be exactly 256 bytes"
            exit 1
        fi    
        EXT="spd"
        OFFSET=0;
        END=255
    fi

    INDEX=0
    while [ $((INDEX+OFFSET)) -le ${END} ]; do
        echo -en "\rWriting to SPD: $((INDEX+OFFSET))/${END} BYTE:(${ARRAYHEX[${INDEX}]})"
        sleep 0.1
        i2cset -y ${BUS} ${DIMM} $((INDEX+OFFSET)) ${ARRAYHEX[${INDEX}]}
        INDEX=$((INDEX+1))
    done

    echo ""
    i2cdump -y $BUS $DIMM b
    echo "${INPUTFILE} written successfully to ${DIMM}"
}

main "$@"
