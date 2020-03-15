#!/usr/bin/python

"""
readspd.py It runs a shell command on the selected bus address and dumps the data
from the smbus

This readspd.py software is provided "as-is" with no warranty, implied or not.
By using this script you agree to proceed at your own risk.
"""

#TODO: implement a way to dump xmp profile 2 and let the user choose either XMP1 or 2

import getopt
import os
import subprocess
import sys
from datetime import date

def main(argv):
    if os.getuid():
        print("Please run as root.")
        sys.exit(1)

    try:
        opts, argv = getopt.getopt(argv, "hxb:d:", ["bus=", "dimm="])
    except getopt.GetoptError:
        print(sys.argv[0], '-x -b <busaddr> -d <dimmaddr>')
        sys.exit(1)

    for opt, arg in opts:
        xmp = False         #its False by default unless the flag is given
        if opt == '-h':
            print(sys.argv[0], '-x -b <busaddr> -d <dimmaddr>')
            print("-x   --xmp | read only from xmp region")
            print("-b   --bus <busaddr> (i.e. 0,1,2,3...)")
            print("-d   --dimm <dimmaddr> (i.e. 0x50,0x21,0x4A)")
            sys.exit(0)
        elif opt in ("-b", "--bus"):
            bus = arg
        elif opt in ("-d", "--dimm"):
            dimm = arg
        elif opt in ("-x", "--xmp"):
            xmp = True

    readspd(bus, dimm, xmp)

def readspd(busaddr, dimmaddr, xmpmode):
    if not os.access('./', os.W_OK):
        print('Cannot write dump to current directory. Check file/folder permissions')
        sys.exit(1)
    else:
        print('WARNING! This program can confuse your I2C bus, cause data loss and worse!')
        print('I will read from device file /dev/i2c-', busaddr, 'chip address', \
                                                        dimmaddr, 'using read byte')
        print('')
        ans = input('Accept the risks and proceed? (yes/y/N/No): ').lower()

        if ans in ['yes', 'y']:
            today = date.today()
            todaysdate = today.strftime("%Y-%m-%d")

            if xmpmode:
                start = 176
                end = 220
                ext = "xmp"
            else:
                start = 0
                end = 256
                ext = "spd"

            spddump = open("dimm{}.{}.{}".format(dimmaddr, todaysdate, ext), 'wb')
            print("Reading....")
            for index in range(start, end):
                i2cproc = subprocess.Popen(['i2cget', '-y', str(busaddr), str(dimmaddr), \
                        str(index)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                output, err = i2cproc.communicate()
                output = output[2:].decode()        #strip '0x' and convert to str
                output = bytes.fromhex(output)      #convert hexstr to 'bytes' type
                print(output, end=' ')
                spddump.write(output)

            print("Dump written to: ./dimm{}.{}.{}".format(dimmaddr, todaysdate, ext))

        else:
            print('User did not type yes/y/Y. No changes have been made. Exiting')
            sys.exit(1)

if __name__ == "__main__":
    main(sys.argv[1:])
