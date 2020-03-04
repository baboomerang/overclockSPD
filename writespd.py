#!/usr/bin/python

"""
writespd.py - takes 3 mandatory options and runs a shell command for every byte in the input file.

this writespd.py software is provided "as-is" with no warranty, implied or not. By using this script you agree to proceed at your own risk.
"""
import os, sys, getopt, subprocess
from pathlib import Path

def main(argv):
    if not.os.geteuid() == 0:
        print ("Please run as root.")
        sys.exit(1)
    try:
       opts, args = getopt.getopt(argv,"hb:d:f:",["BUS=","DIMM=","INPUTPATH="])
    except getopt.error:
      print (sys.argv[0],'-b <bus addr> -d <dimm addr> -f <filepath>')
      sys.exit(1)

    for opt, arg in opts:
        if opt == '-h':
            print (sys.argv[0],'-b <bus addr> -d <dimm addr>')
            sys.exit()
        elif opt in ("-b", "--bus"):
            BUS = arg
        elif opt in ("-b", "--dimm"):
            DIMM = arg
        elif opt in ("-f", "--file"):
            INPUTPATH = arg

def writeSPD(BUS,DIMM,INPUTPATH):
    INPUTSPD = Path(str(INPUTPATH))

    if INPUTSPD.is_file() is None:
        print ('Input file not found.')
        sys.exit(1)
    else:
        file = open(INPUTSPD,"rb")
        for index in range(0,255):
            hexbyte = file.read(1);
            file.seek(1);
            print(hexbyte);
            subprocess.call('i2cset',bus,dimm,index,hexbyte,shell=True)


if __name__ == "__main__":
   main(sys.argv[1:])

