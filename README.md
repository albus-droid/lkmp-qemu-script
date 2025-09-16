## RUN THESE INSIDE YOUR GUEST VM
# mount host folder (read-only for safety)
mkdir -p /mnt/host
mount -t 9p -o ro,trans=virtio,version=9p2000.L hostshare /mnt/host

# (optional) mount the syz "disk image" and corrupt fs
mkdir -p /mnt/syzdisk /mnt/corrupt
[ -e /dev/sdb ] && mount -o ro /dev/sdb /mnt/syzdisk
[ -e /dev/sdc ] && mount -t ext4 -o ro,noload /dev/sdc /mnt/corrupt

# If your guest HAS gcc:
cp /mnt/host/repro.c /root/
gcc -O2 -static -pthread /root/repro.c -o /root/repro
/root/repro
