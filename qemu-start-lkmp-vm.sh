#!/bin/bash
set -euxo pipefail

KERNEL=${KERNEL:-$(find . -name 'bzImage-*' 2>/dev/null | head -n1)}
[ -n "$KERNEL" ] || { echo "No bzImage-* found in $(pwd)"; exit 1; }

# Modify parameters however you want.
KPARAM="console=ttyS0,115200 root=/dev/sda ro earlyprintk=serial net.ifnames=0 nokaslr"

MYROOTFS="./stretch.img"            
SYZDISK=${SYZDISK:-$(find . -name 'disk*' 2>/dev/null | head -n1 || true)}
CORRUPT=${CORRUPT:-$(find . -name 'mount_*' 2>/dev/null | head -n1 || true)}

qemu-system-x86_64 -m 2048 -smp 2 -cpu host -enable-kvm -nographic \
  -kernel "$KERNEL" \
  -append "$KPARAM" \
  -drive file="$MYROOTFS",if=ide,format=raw,index=0 \
  -drive file="$SYZDISK",if=ide,format=raw,index=1 \
  -drive file="$CORRUPT",if=ide,format=raw,index=2 \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:10022-:22 \
  -virtfs "local,id=fs0,path=$PWD,security_model=none,mount_tag=hostshare" \
  -device e1000,netdev=net0 -s

