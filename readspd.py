#!/usr/bin/python

"""
readspd.py It runs a shell command on the selected bus address and dumps the data
from the smbus

This readspd.py software is provided "as-is" with no warranty, implied or not.
By using this script you agree to proceed at your own risk.
"""

import getopt
import os
import subprocess
import sys

def main(argv):
    if os.getuid():
        print("Please run as root.")
        sys.exit(1)

    try:
        opts, args = getopt.getopt(argv, "hb:d:", ["bus=", "dimm="])
    except getopt.error:
        print(sys.argv[0], '-b <bus addr> -d <dimm addr>')
        sys.exit(1)

    for opt, arg in opts:
        if opt == '-h':
            print(sys.argv[0], '-b <bus addr> -d <dimm addr>')
            sys.exit(0)
        elif opt in ("-b", "--bus"):
            bus = arg
        elif opt in ("-d", "--dimm"):
            dimm = arg

    readSPD(bus, dimm)

def readSPD(busaddr, dimmaddr):
    if not os.access('./', os.W_OK):
        print('Cannot write dump to current directory')
        sys.exit(1)
    else:
        print('WARNING! This program may confuse your i2c bus')
        ans = input('(y/N) << ').lower()
        if ans in ['yes', 'y']:
            for index in range(0, 255):
                getbyte = subprocess.Popen(['i2cget', str(busaddr), str(dimmaddr), \
                        str(index)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                output, err = getbyte.communicate()
                print(output)
        else:
            print('User did not type yes/y/Y. No changes have been made. Exiting')
            sys.exit(1)

if __name__ == "__main__":
    main(sys.argv[1:])
