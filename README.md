# overclockSPD
Fast and easy ways to read and write data to RAM SPD. 
_\*will also include a gui for overclocking ram_

These are scripts that provide linux users with tools to easily modify data (timings, voltages, configuration...)
from multiple sticks of RAM. Other tools currently out there such as Taiphoon Burner, TB2BIN, RWEVERYTHING... only run on Windows. (which is unfortunate)

***It can also convert .emp files (created by Thaiphoon Burner) into .xmp files.***
  
  
Directly inspired by the man who created the amazing tb2bin tool: [Valuxin](http://forum.notebookreview.com/members/valuxin.400286/)

[Background Info on RAMOC and TB2BIN](http://forum.notebookreview.com/threads/guide-how-to-overclock-and-change-timings-for-any-ram-on-most-laptops.805589/)  

DISCLAIMER
------------------------------------------------
```
DISCLAIMER: This "overclockSPD" is provided by baboomerang (the writer & provider of this software)\
"as is" and "with all faults." baboomerang (the writer & provider of this software)\
makes no representations or warranties of any kind concerning the safety,\
suitability, lack of viruses, inaccuracies, typographical errors, or other harmful\
components of this "overclockSPD". There are inherent dangers in the use of any software,\
and you are solely responsible for determining whether this "overclockSPD" is compatible \
with your equipment and other software installed on your equipment. You are also solely \
responsible for the protection of your equipment and backup of your data, and\
baboomerang (the writer & provider of this software) will not be liable for any damages\
you may suffer in connection with using, modifying, or distributing this "overclockSPD" or any part of it.
```
WARNING: WRITING TO NON-DIMM LOCATIONS CAN CAUSE DAMAGE/BRICKS. HAVE CAUTION BEFORE WRITING ANY DATA THROUGH THE SMBUS
--------------------------------------------------

#### Install
###### You need to have ***i2c_dev*** and ***i2c_i801*** modules loaded. Also make sure the ***i2c-tools*** package is installed.
```
sudo pacman -S i2c-tools
sudo modprobe i2c_i801
sudo modprobe i2c_dev
```
Usually i2c-i801 is loaded by default on Arch, but its included here incase it isn't for your distro.

 
### Usage

```
Usage: sudo ./readspd.sh [-x]xmp [-b busaddr] [-d dimaddr <0x##>]              # only writes 1 target at a time
       sudo ./writespd.sh [-x]xmponly [-b busaddr#] [-d dimaddr <0x##>] [FILE] # only writes 1 target at a time
       sudo python readspd.py -x -b <busaddr> -d <dimmaddr>                    # only reads 1 target at a time
       sudo python writespd.py -x -b <busaddr> -d <dimmaddr> -f <filepath>     # only writes 1 target at a time

```
Results will be saved in the same WD as input file. Check if there is write access to it otherwise the scripts will fail.

**Examples**
```
./readspd.sh -b 9 -d 0x50
./writespd.sh -b 9 -d 0x50 ./ocdumpprofile.spd
python readspd.py -b 9 -d 0x50
python writespd.py -b 9 -d 0x50 -f ./ocdumpprofile.spd
```
*OUTPUT*:
```
$ ls
dimm0x50.spd  dimm0x51.spd  dimm0x52.spd  dimm0x53.spd
```
DUMPED CONTENT
--------------------------------------------------------------------------------
```
 $ xxd dimm0x50.2020-02-20.spd 
00000000: 9211 0b03 0421 0209 0311 0108 0900 fe00  .....!..........
00000010: 5f78 5f28 5f11 106f 2008 3c3c 00c8 8305  _x_(_..o .<<....
00000020: 0000 ca97 9797 9700 0000 0000 0000 0000  ................
00000030: 0000 0000 0000 0000 0000 0000 0f11 0500  ................
00000040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000050: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000070: 0000 0000 0004 cd00 0000 0000 0000 3366  ..............3f
00000080: 4633 2d31 3836 3643 3131 2d38 4752 534c  F3-1866C11-8GRSL
00000090: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000000a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000000b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000000c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000000d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000000e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000000f0: ff00 0000 0000 0000 0000 0000 0000 0000  ................
```
*EMP FILE CONTENTS* (Made by Thaiphoon Burner)  

```
$ xxd 2133_11_12_13_34_2T.emp
00000000: 0558 4d50 3133 0001 0e2a 0d8f 82aa 9cd2  .XMP13...*......
00000010: 4669 0000 001a fc03 be01 6c02 6e00 380e  Fi........l.n.8.
00000020: 5e01 6900 0011 0800 0000 0000 0000 0000  ^.i.............
00000030: 0000 0000                                ....
```
*CONVERTED EMP TO XMP CONTENTS* (Made by emp2xmp)  

```
$ xxd 2133_11_12_13_34_2T.emp.2020-02-20.xmp
00000000: 0c4a 0513 010e 0000 112a 0d8f fc03 82aa  .J.......*......
00000010: 9cd2 21be 6c6e 0038 0e69 4600 5e69 0000  ..!.ln.8.iF.^i..
00000020: 1a00 0008 0000 0000                      ........
```
