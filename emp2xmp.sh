usage() { echo "Usage: $0 <empfile>" 1>&2; exit 1; }

main() {
    if [ ! $# = 2 ]; then
        usage
    else
        EMPFILE=$1

        if [ ! -f ${EMPFILE} ]; then
            echo "Not a valid emp file!"
            usage
        fi

        DATE=$(date +%Y-%m-%d)
        CONVERTEDFILE="${1}.${DATE}.xmp"
        echo "" | tr -d '\n' > ${CONVERTEDFILE}

        if [ $? -ne 0 ]; then
            echo "Error writing new file. Check file/folder permissions and try again"
            exit 1
        fi

        printf "\x0c" >> ${CONVERTEDFILE}           #xmp magic number
        printf "\x4a" >> ${CONVERTEDFILE}           #xmp magic number
        printf "\x05" >> ${CONVERTEDFILE}
    # 00   |    00                           00          |      0        0
# reserved | prfl2 dimmsPerchannel    prfl1 dimmsPerchnl |   profile2 profile1
        # result: 0x05 =   0000 0101
        # profile 1 enabled
        # 2 dimms per channel

        #printf "\x${EMPFILE[4]}" >> #emp 4&5th bytes are xmp version #
        printf "\x${EMPFILE[7]}" >> ${CONVERTEDFILE} #xmp profile 1 MTB dividend
        printf "\x${EMPFILE[8]}" >> ${CONVERTEDFILE} #xmp profile 1 MTB divisor
        printf "\x00" >> ${CONVERTEDFILE}            #xmp profile 2 MTB dividend
        printf "\x00" >> ${CONVERTEDFILE}            #xmp profile 2 MTB divisor
        printf "\x${EMPFILE[37]}" >> ${CONVERTEDFILE}#reserved byte
        printf "\x${EMPFILE[9]}" >> ${CONVERTEDFILE} #DIMM VOLTAGE
        printf "\x${EMPFILE[10]}" >> ${CONVERTEDFILE}#tCK minimum
        printf "\x${EMPFILE[11]}" >> ${CONVERTEDFILE}#tAA minimum
        printf "\x${EMPFILE[22]}" >> ${CONVERTEDFILE}
        printf "\x${EMPFILE[23]}" >> ${CONVERTEDFILE}
        printf "\x${EMPFILE[12]}" >> ${CONVERTEDFILE}#tcWL minimum
        printf "\x${EMPFILE[13]}" >> ${CONVERTEDFILE}#tRP  minimum
        printf "\x${EMPFILE[14]}" >> ${CONVERTEDFILE}#tRCD minimum
        printf "\x${EMPFILE[15]}" >> ${CONVERTEDFILE}#tWR  minimum
#19th byte checksum
        HEXBYTE=$(cat ${EMPFILE[24]} | xxd -p -c 256 | sed -ne 's/./&/p' | tr -d '\n')

        printf "\x${EMPFILE[24]}" >> ${CONVERTEDFILE}#tRAS minimum
        printf "\x${EMPFILE[26]}" >> ${CONVERTEDFILE}#tRC  minimum
        printf "\x${EMPFILE[28]}" >> ${CONVERTEDFILE}#tREFI max   lower byte
        printf "\x${EMPFILE[29]}" >> ${CONVERTEDFILE}#tREFI max   upper byte
        printf "\x${EMPFILE[30]}" >> ${CONVERTEDFILE}#tRFC min    lower byte
        printf "\x${EMPFILE[31]}" >> ${CONVERTEDFILE}#tRFC min    upper byte
        printf "\x${EMPFILE[34]}" >> ${CONVERTEDFILE}#tRTP min
        printf "\x${EMPFILE[16]}" >> ${CONVERTEDFILE}#tRRD min
        printf "\x00" >> ${CONVERTEDFILE}            #28th byte skipped -ZEROED
        printf "\x${EMPFILE[32]}" >> ${CONVERTEDFILE}#tFAW min upper nibble
        printf "\x${EMPFILE[17]}" >> ${CONVERTEDFILE}#tFAW min byte
        printf "\x00" >> ${CONVERTEDFILE}            #31st byte skipped -ZEROED
        printf "\x00" >> ${CONVERTEDFILE}            #32nd byte skipped -ZEROED
        printf "\x${EMPFILE[21]}" >> ${CONVERTEDFILE}#tWTR min
        printf "\x00" >> ${CONVERTEDFILE}            #34th byte skipped -ZEROED
        printf "\x${EMPFILE[36]}" >> ${CONVERTEDFILE}
        printf "\x${EMPFILE[38]}" >> ${CONVERTEDFILE}
        printf "\x${EMPFILE[39]}" >> ${CONVERTEDFILE}
        printf "\x${EMPFILE[40]}" >> ${CONVERTEDFILE}
        printf "\x${EMPFILE[41]}" >> ${CONVERTEDFILE}
        printf "\x${EMPFILE[42]}" >> ${CONVERTEDFILE}
    fi

}
