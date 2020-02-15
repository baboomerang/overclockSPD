# readspd
Read and Write to RAM SPD (similar to Tb2Bin)

### How-to
```
./readspd.sh [bus] [dimmaddr]  optional:[dimmaddr2] [dimmaddr3] [dimmaddr4]"
```

**Example**
```
./readspd.sh 9 0x50 0x51 0x52 0x53
```
OUTPUT:
```
$ ls
dimm0x50.spd  dimm0x51.spd  dimm0x52.spd  dimm0x53.spd
```
