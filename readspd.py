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
        opts, argv = getopt.getopt(argv, "hb:d:", ["busaddr=", "dimmaddr="])

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

def readSPD(bus, dimm):
    if os.access('./', os.W_OK):
        print('Cannot write dump to current directory')
        sys.exit(1)
    else:
        for index in range(0, 255):
            i2cget_proc = subprocess.Popen(['i2cget', bus, dimm, index], \
                    stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, err = i2cget_proc.communicate()


if __name__ == "__main__":
    main(sys.argv[1:])
