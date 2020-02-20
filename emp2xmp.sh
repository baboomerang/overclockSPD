#!/bin/sh

usage() { echo "Usage: $0 <empfile>" 1>&2; exit 1; }

main() {
    if [ $# -lt 1 ]; then
        usage
    else
        EMPFILE=$1

        if [ ! -f ${EMPFILE} ]; then
            echo "Not a valid emp file!"
            usage
        fi

        RAWHEX=$(cat ${EMPFILE} | xxd -p -c 256 | tr -d '\n'| sed -e 's/../& /g')
        #all of the EMPFILE is stored into the first element of the RAWHEX array.

        ARRAYHEX=($RAWHEX)
        HEXFILELEN=${#ARRAYHEX[@]}

        if [ ${HEXFILELEN} != 52 ]; then
            echo "EMP File size must be 52 bytes!"
            exit 1
        fi

        DATE=$(date +%Y-%m-%d)
        CONVERTEDFILE="${1}.${DATE}.xmp"
        echo "" | tr -d '\n' > "${CONVERTEDFILE}"

        if [ $? -ne 0 ]; then
            echo "Error writing new file. Check file/folder permissions and try again"
            exit 1
        fi

        echo "Creating file and writing header"
        printf "\x0c" >> ${CONVERTEDFILE}           #xmp magic number
        printf "\x4a" >> ${CONVERTEDFILE}           #xmp magic number
        printf "\x05" >> ${CONVERTEDFILE}
    #the 3rd bit in every XMP profile depends on the system ram config
    #you can configure it to your liking with the description of the byte below
    #                1 byte =  0000 0000  (8 bits)
    #   00   |    00                           00          |      0        0
  # reserved | prfl2 dimmsPerchannel    prfl1 dimmsPerchnl |   profile2 profile1
        # result: 0x05 =   0000 0101
        # so profile 1 enabled
        # and 2 dimms per channel

        echo "${ARRAYHEX[@]}"
        XMPMAJORVERSION=${ARRAYHEX[4]}                    #31 -> 1
        XMPMAJORVERSION=${XMPMAJORVERSION:1:1}

        XMPMINORVERSION=${ARRAYHEX[5]}                    #33 -> 3
        XMPMINORVERSION=${XMPMINORVERSION:1:1}
                                                          #0x13 -> file
        printf "\x${XMPMAJORVERSION}${XMPMINORVERSION}" >> ${CONVERTEDFILE}

        printf "\x${ARRAYHEX[7]}" >> ${CONVERTEDFILE}     #xmp profile 1 MTB dividend
        printf "\x${ARRAYHEX[8]}" >> ${CONVERTEDFILE}     #xmp profile 1 MTB divisor
        printf "\x00" >> ${CONVERTEDFILE}                 #xmp profile 2 MTB dividend
        printf "\x00" >> ${CONVERTEDFILE}                 #xmp profile 2 MTB divisor
        printf "\x${ARRAYHEX[37]}" >> ${CONVERTEDFILE}    #reserved byte
        printf "\x${ARRAYHEX[9]}" >> ${CONVERTEDFILE}     #DIMM VOLTAGE (usually has no effect)
        printf "\x${ARRAYHEX[10]}" >> ${CONVERTEDFILE}    #tCK minimum
        printf "\x${ARRAYHEX[11]}" >> ${CONVERTEDFILE}    #tAA minimum
        printf "\x${ARRAYHEX[22]}" >> ${CONVERTEDFILE}    #CAS (list of supported latencies)
        printf "\x${ARRAYHEX[23]}" >> ${CONVERTEDFILE}    #CAS (list of supported latencies)
        printf "\x${ARRAYHEX[12]}" >> ${CONVERTEDFILE}    #tcWL minimum
        printf "\x${ARRAYHEX[13]}" >> ${CONVERTEDFILE}    #tRP  minimum
        printf "\x${ARRAYHEX[14]}" >> ${CONVERTEDFILE}    #tRCD minimum
        printf "\x${ARRAYHEX[15]}" >> ${CONVERTEDFILE}    #tWR  minimum
        
        # in the ddr3 spec, these nibbles should be reversed
        # i.e. it should be 0x01 then 0x02
        # but instead this script will preserve what tb2bin does
        
        UPPERtRASNIBBLE=${ARRAYHEX[27]}                   # 02 -> 2
        UPPERtRASNIBBLE=${UPPERtRASNIBBLE:1:1}            

        UPPERtRCNIBBLE=${ARRAYHEX[25]}                    # 01 -> 1
        UPPERtRCNIBBLE=${UPPERtRCNIBBLE:1:1}
                                                          # 0x21 -> file
        printf "\x${UPPERtRASNIBBLE}${UPPERtRCNIBBLE}" >> ${CONVERTEDFILE}

        printf "\x${ARRAYHEX[24]}" >> ${CONVERTEDFILE}    #tRAS minimum     #byte 195
        printf "\x${ARRAYHEX[26]}" >> ${CONVERTEDFILE}    #tRC  minimum
        printf "\x${ARRAYHEX[28]}" >> ${CONVERTEDFILE}    #tREFI max   lower byte
        printf "\x${ARRAYHEX[29]}" >> ${CONVERTEDFILE}    #tREFI max   upper byte
        printf "\x${ARRAYHEX[30]}" >> ${CONVERTEDFILE}    #tRFC min    lower byte
        printf "\x${ARRAYHEX[31]}" >> ${CONVERTEDFILE}    #tRFC min    upper byte
        printf "\x${ARRAYHEX[34]}" >> ${CONVERTEDFILE}    #tRTP min
        printf "\x${ARRAYHEX[16]}" >> ${CONVERTEDFILE}    #tRRD min
        printf "\x00" >> ${CONVERTEDFILE}                 #28th byte skipped -ZEROED
        printf "\x${ARRAYHEX[32]}" >> ${CONVERTEDFILE}    #tFAW min upper nibble
        printf "\x${ARRAYHEX[17]}" >> ${CONVERTEDFILE}    #tFAW min byte
        printf "\x00" >> ${CONVERTEDFILE}                 #31st byte skipped -ZEROED
        printf "\x00" >> ${CONVERTEDFILE}                 #32nd byte skipped -ZEROED
        printf "\x${ARRAYHEX[21]}" >> ${CONVERTEDFILE}    #tWTR min         #byte 205
        printf "\x00" >> ${CONVERTEDFILE}                 #34th byte skipped -ZEROED
        printf "\x${ARRAYHEX[36]}" >> ${CONVERTEDFILE}    #CMD-turnaround adjustment
        printf "\x${ARRAYHEX[38]}" >> ${CONVERTEDFILE}    #SYSTEM CMD ratemode byte208
        printf "\x${ARRAYHEX[39]}" >> ${CONVERTEDFILE}    #SDRAM autoself refresh byte209
        printf "\x${ARRAYHEX[40]}" >> ${CONVERTEDFILE}    #byte 210 [reserved]
        printf "\x${ARRAYHEX[41]}" >> ${CONVERTEDFILE}    #byte 211 [reserved] magic#?
        printf "\x${ARRAYHEX[42]}" >> ${CONVERTEDFILE}    #byte 212 [reserved]
        echo "Converted file written to ${CONVERTEDFILE}"
    fi
}

main "$@"
