# readspd
A fast and easy way to read and write data to RAM SPD.


Shell scripts that provide linux users with tools to easily modify data (timings, voltages, configuration...)
from multiple sticks of RAM. Other tools currently out there such as Taiphoon Burner, TB2BIN, RWEVERYTHING... only run on Windows.


***It can also convert .emp files (created by Thaiphoon Burner) into .xmp files.***
  
  
Directly inspired by the man who created the amazing tb2bin tool: [Valuxin](http://forum.notebookreview.com/members/valuxin.400286/)

[Background Info on RAMOC and TB2BIN](http://forum.notebookreview.com/threads/guide-how-to-overclock-and-change-timings-for-any-ram-on-most-laptops.805589/)  

### How-to

#### You need to have ***i2c_dev*** and ***i2c_i801*** modules loaded. Also make sure the ***i2c-tools*** package is installed.
```
Usage: ./readspd.sh [-x]xmp [-b busaddr] [-d dimaddr <0x##>] optional:[dimmaddr2] [dimmaddr3] [dimmaddr4]

```
Results will be saved in the same WD as input file. Check if there is write access to it otherwise the scripts will fail.

**Example**
```
./readspd.sh -b 9 -d 0x50 0x51 0x52 0x53
```
*OUTPUT*:
```
$ ls
dimm0x50.spd  dimm0x51.spd  dimm0x52.spd  dimm0x53.spd
```
FILE CONTENTS
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
