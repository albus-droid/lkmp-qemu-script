## RUN THESE INSIDE YOUR GUEST VM
```bash # mount host folder (read-only for safety)
mkdir -p /mnt/host
mount -t 9p -o trans=virtio,version=9p2000.L,rw hostshare /mnt/host

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
make mrproper
```
## TOOLS
### TRACERS
```bash
# Enable kprobes
scripts/config -e CONFIG_KPROBES
scripts/config -e CONFIG_KPROBE_EVENTS
scripts/config -e CONFIG_UPROBE_EVENTS
scripts/config -e CONFIG_KPROBE_EVENTS_ON_NOTRACE
scripts/config -e CONFIG_OPTPROBES

# Also enable related tracing features
scripts/config -e CONFIG_DYNAMIC_FTRACE
scripts/config -e CONFIG_DYNAMIC_FTRACE_WITH_REGS
scripts/config -e CONFIG_FUNCTION_TRACER
scripts/config -e CONFIG_FUNCTION_GRAPH_TRACER
scripts/config -e CONFIG_STACK_TRACER

# Enable BPF support (useful for bpftrace later)
scripts/config -e CONFIG_BPF
scripts/config -e CONFIG_BPF_SYSCALL
scripts/config -e CONFIG_BPF_JIT
scripts/config -e CONFIG_HAVE_EBPF_JIT

# Verify changes
scripts/config --state CONFIG_KPROBES
scripts/config --state CONFIG_KPROBE_EVENTS
```
