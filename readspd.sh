#!/bin/bash

# Project: readspd - a RAM SPD reading tool similar to TB2BIN
# Author: baboomerang https://github.com/baboomerang/
# Date: 02/15/2020

# READSPD.sh ===============================================================
# Make sure i2c_dev, i2c_i801, i2c_algo_bit are loaded.
# This should read the spd data of the RAM (255 bytes) and write it to a file named 
# dimm{hex-address}.spd in the current PWD

<<COMMENT
DISCLAIMER: This "readspd" script is provided by baboomerang (the writer & provider of this software)\
"as is" and "with all faults." baboomerang (the writer & provider of this software)\
makes no representations or warranties of any kind concerning the safety,\
suitability, lack of viruses, inaccuracies, typographical errors, or other harmful\
components of this "readspd" script. There are inherent dangers in the use of any software,\
and you are solely responsible for determining whether this "readspd" script is compatible \
with your equipment and other software installed on your equipment. You are also solely \
responsible for the protection of your equipment and backup of your data, and\
baboomerang (the writer & provider of this software) will not be liable for any damages\
you may suffer in connection with using, modifying, or distributing this "readspd" script.
COMMENT

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

main() {
if [[ $# -lt 2 ]] ;
then
    echo "Not enough arguments."
    echo "Use i2cdetect -lt to get bus address & i2cdetect -y [busaddr] for DIMMaddr"
    echo "Usage: readspd.sh [bus] [dimmaddr]  optional:[dimmaddr2] [dimmaddr3] [dimmaddr4]"
    exit 1

else
    BUS=$1
    DIMM=$2
    readSPD $DIMM

    if [[ ! $3 -eq 0 ]];
    then
        DIMM2=$3
        readSPD $DIMM2
    fi

    if [[ ! $4 -eq 0 ]];
    then 
        DIMM3=$4
        readSPD $DIMM3
    fi

    if [[ ! $5 -eq 0 ]];
    then
        DIMM4=$5
        readSPD $DIMM4
    fi
fi
}

readSPD() {
    echo "" | tr -d '\n' > dimm${1}.spd 
    for DATADDR in {0..255}; 
    do 
        HEX=$(i2cget -y ${BUS} ${1} ${DATADDR} | sed -ne 's/^0x\(.*\)/\1/p')
        printf "\x${HEX}" >> dimm${1}.spd
        # printf cant be saved to a bash variable, the output must be sent to a file
        # alternatively, echo -e is not posix compliant so printf is the easiest way.
    done 
}

main "$@"
