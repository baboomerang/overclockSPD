#!/usr/bin/python

"""
readspd.py It runs a shell command on the selected bus address and dumps the data 
from the smbus

this readspd.py software is provided "as-is" with no warranty, implied or not. By using this script you agree to proceed at your own risk.
"""
import os, sys, getopt, subprocess
from pathlib import Path

def main(argv):
    if not.os.geteuid() == 0:
        print ("Please run as root.")
        sys.exit(1)
    try:
        opts, args = getopt.getopt(argv,"hb:d:",["bus=","dimm="])

    except getopt.error:
        print (sys.argv[0],'-b <bus addr> -d <dimm addr>')
        sys.exit(1)

    for opt, arg in opts:
        if opt == '-h':
            print (sys.argv[0],'-b <bus addr> -d <dimm addr>')
            sys.exit(0)
        elif opt in ("-b", "--bus"):
            BUS = arg
        elif opt in ("-b", "--dimm"):
            DIMM = arg

def readspd(BUS,DIMM):
    if #check for file write capability in CWD first 
        print ('Cannot write dump to current directory')
        sys.exit(1)
    else:
        for INDEX in range(0,255):
            subprocess.call('i2cget',BUS,DIMM,INDEX)
            #somehow assign result returned from this command 


if __name__ == "__main__":
   main(sys.argv[1:])

