#!/usr/bin/python

"""
writespd.py - takes 3 mandatory options and runs a shell command for every byte.

This writespd.py software is provided "as-is" with no warranty, implied or not.
By using this script you agree to proceed at your own risk.
"""

import os
import sys
import getopt
import subprocess
from pathlib import Path

def main(argv):
    if os.getuid():
        print("Please run as root.")
        sys.exit(1)

    try:
        opts, argv = getopt.getopt(argv, "hxb:d:f:", ["bus=", "dimm=", "filepath="])
    except getopt.error:
        print(sys.argv[0], '-x -b <busaddr> -d <dimmaddr> -f <filepath>')
        sys.exit(1)

    for opt, arg in opts:
        if opt == '-h':
            print(sys.argv[0], '-x -b <busaddr> -d <dimmaddr> -f <filepath>')
            print("-x       --xmp | write only to xmp region")
            print("-b       --bus <busaddr> (i.e. 0,1,2,3...)")
            print("-d       --dimm <dimmaddr> (i.e. 0x50,0x21,0x4A")
            print("-f       --file <filepath> (i.e. ./foo/bar/ocprofile.spd")
            sys.exit(0)
        elif opt in ("-b", "--bus"):
            bus = arg
        elif opt in ("-b", "--dimm"):
            dimm = arg
        elif opt in ("-f", "--file"):
            inputpath = arg
        elif opt in ("-x", "--xmp"):
            xmp = true

    writespd(bus, dimm, inputpath)

def writespd(busaddr, dimmaddr, filepath):
    spdfile = Path(str(filepath))

    if not spdfile.is_file():
        print('Input file not found.')
        sys.exit(1)
    else:
        print('WARNING! This program can confuse your I2C bus, cause data loss and worse!')
        print('I will write to device file /dev/i2c-', busaddr, 'chip address', dimmaddr, \
              ', using write byte')

        ans = input('Accept the risks and proceed? (yes/y/N/No): ').lower()
        if ans in ['yes', 'y']:
            spdfile = open(spdfile, "rb")
            for _ in range(0, 256):
                byte = spdfile.read(1)
                spdfile.seek(1)
                print(byte)
                i2cset_proc = subprocess.Popen(['i2cset', '-y', bus, dimm, byte], \
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                output, err = i2cset_proc.communicate()
        else:
            print('User did not type yes/y/Y. No changes have been made. Exiting')
            sys.exit(1)

if __name__ == "__main__":
    main(sys.argv[1:])
