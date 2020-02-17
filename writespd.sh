#!/bin/bash

# Project: readspd - a RAM SPD reading tool similar to TB2BIN
# Author: baboomerang https://github.com/baboomerang/
# Date: 02/15/2020


# WRITESPD.sh ========================================================
# Make sure i2c_dev, i2c_i801, i2c_algo_bit are loaded.
# This should write to the spd of the ram from a file (255 bytes) long.
# For saftey reasons this writes to only one spd at a time.

<<COMMENT
DISCLAIMER: This "writespd" script is provided by baboomerang (the writer & provider of this software)\
"as is" and "with all faults."baboomerang (the writer & provider of this software)\
makes no representations or warranties of any kind concerning the safety,\
suitability, lack of viruses, inaccuracies, typographical errors, or other harmful\
components of this "writespd" script. There are inherent dangers in the use of any software,\
and you are solely responsible for determining whether this "writespd" script is compatible \
with your equipment and other software installed on your equipment. You are also solely \
responsible for the protection of your equipment and backup of your data, and\
baboomerang (the writer & provider of this software) will not be liable for any damages\
you may suffer in connection with using, modifying, or distributing this "writespd" script.
COMMENT

if [ "$EUID" -ne 0 ];
    then echo "Please run as root"
    exit
fi

main() {
    if [ $# -lt 3 ]; then
        echo "Not enough arguments. Double check file path, and or DIMM address."
        echo "Usage: writespd.sh [bus] [dimmaddr] [file]"
        exit 1
    else
        BUS=$1
        DIMM=$2
        INPUTFILE=$3
    
        echo "WARNING! Do not write incorrect or bad address for bus/dimm!"
        echo "Writing to non-dimm locations can cause damage!"
        sleep 1
     
        i2cdump -y ${BUS} ${DIMM}
        echo "Preview of target device: is this the one you want?" 
        sleep 1
    
        read -p "Knowing these risks, you will write to ${BUS} ${DIMM} Proceed? [yesiwanttoproceedknowingtheserisks/no]: " yn
        case $yn in
            yesiwanttoproceedknowingtheserisks ) writeSPD DIMM
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

    INPUTFILELEN=${#INPUTFILE[@]}
    
    if [ INPUTFILELEN != 256 ]; then
        echo "File must be exactly 256 bits"
        exit 1
    fi

    HEX=$(cat $INPUTFILE | xxd -p -c 256 | sed -e 's/../0x& /g' | tr -d '\n')
    # i2cset only takes singular input values starting with "0x" i.e. 0x9F
    for INDEX in {0..255}; do
            i2cset -y ${BUS} ${DIMM} ${INDEX} ${HEX[${INDEX}]}
    done

}

main "$@"
