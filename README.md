## RUN THESE INSIDE YOUR GUEST VM
```bash # mount host folder (read-only for safety)
mkdir -p /mnt/host
mount -t 9p -o ro,trans=virtio,version=9p2000.L hostshare /mnt/host

# (optional) mount the syz "disk image" and corrupt fs
mkdir -p /mnt/syzdisk /mnt/corrupt
[ -e /dev/sdb ] && mount -o ro /dev/sdb /mnt/syzdisk
[ -e /dev/sdc ] && mount -t ext4 -o ro,noload /dev/sdc /mnt/corrupt

# If your guest HAS gcc:
cp /mnt/host/repro.c /root/
gcc -O2 -pthread /root/repro.c -o /root/repro
/root/repro
```
## COMPILING THE KERNEL
### WITH GCC
```bash
yes "" | make oldconfig
make -j"$(nproc)" bzImage vmlinux
```
### WITH CLANG
```bash
yes "" | make -j"$(nproc)" LL(nproc)" LLVM=1 vmlinux bzImage
```
## CLEANING SOURCES
```bash
make clean
make mrproper```
