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
if [ $# -lt 3 ];
    echo "Not enough arguments. Double check file path, and or DIMM address."
    echo "Usage: writespd.sh [bus] [dimmaddr] [file]"
    exit 1
else
    BUS=$1
    DIMM=$2
    
    echo "WARNING! Do not write incorrect or bad address for bus/dimm!"
    echo "Writing to non-dimm locations will 100% cause bricks!"
    i2cdetect -lt
    
    echo "Preview of target device: is this the one you want?"
    i2cdetect -y ${BUS} ${DIMM}
    
    read -p "Knowing these risks, you will write to ${BUS} ${DIMM} Proceed? [yesiwanttoproceedknowingtheserisks/no]: " yn
    case $yn in
        yesiwanttoproceedknowingtheserisks ) writeSPD DIMM
        no ) exit 1;;
        * ) echo "Error: response must be exact option, verbatim as given."; exit 1;;
    esac
fi
}

writeSPD() {
    for DATAADDR in {0..255};
    do
        if [ $? -e 0 ];
        then

        else
            echo "WARNING! Incorrect/bad address for bus/dimm!"
            echo "Writing to non-dimm locations will cause bricks!"
            exit 1
        fi
    done
}

main "$@"
