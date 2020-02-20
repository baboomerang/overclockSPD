# readspd
A fast and easy way to read and write data to RAM SPD.


Shell scripts that provide linux users with tools to easily modify data (timings, voltages, configuration...)
from multiple sticks of RAM. Other tools currently out there such as Taiphoon Burner, TB2BIN, RWEVERYTHING... only run on Windows. Other scripts work but don't save the data in a compatbile format.

***It can also convert .emp files*** (created by Thaiphoon Burner) into .xmp files.


This project aims to make the transition from those Windows-based utilities much easier.

Directly inspired by the man who created the amazing tb2bin tool: Valuxin
Program Link: http://forum.notebookreview.com/threads/guide-how-to-overclock-and-change-timings-for-any-ram-on-most-laptops.805589/
Author: http://forum.notebookreview.com/members/valuxin.400286/

### How-to

#### You need to have ***i2c_dev*** and ***i2c_i801*** modules loaded. Also make sure ***i2c-tools*** package is installed.
```
Usage: ./readspd.sh [-x]xmp [-b busaddr] [-d dimaddr <0x##>] optional:[dimmaddr2] [dimmaddr3] [dimmaddr4]

```
Results will be saved in the same WD as input file. Make sure you have write access to it otherwise the scripts will fail.

**Example**
```
./readspd.sh -b 9 -d 0x50 0x51 0x52 0x53
```
*OUTPUT*:
```
$ ls
dimm0x50.spd  dimm0x51.spd  dimm0x52.spd  dimm0x53.spd
```
