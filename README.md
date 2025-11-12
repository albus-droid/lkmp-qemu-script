## CREATING BASE IMAGE
[create-image.sh](https://android.googlesource.com/platform/external/syzkaller/+/HEAD/tools/create-image.sh)
or direct download from [here](https://storage.googleapis.com/syzkaller/stretch.img)
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
yes "" | make -j"$(nproc)" LLVM=1 vmlinux bzImage
```
## CLEANING SOURCES
```bash
make clean
make mrproper
```
## TOOLS
### TRACING AND KPROBES
```bash
# Kprobes
scripts/config -e CONFIG_KPROBES
scripts/config -e CONFIG_KPROBE_EVENTS
scripts/config -e CONFIG_UPROBE_EVENTS
scripts/config -e CONFIG_OPTPROBES

# Dynamic ftrace
scripts/config -e CONFIG_FTRACE
scripts/config -e CONFIG_FUNCTION_TRACER
scripts/config -e CONFIG_FUNCTION_GRAPH_TRACER
scripts/config -e CONFIG_DYNAMIC_FTRACE
scripts/config -e CONFIG_DYNAMIC_FTRACE_WITH_REGS
scripts/config -e CONFIG_STACK_TRACER

# Tracepoints
scripts/config -e CONFIG_TRACEPOINTS
scripts/config -e CONFIG_TRACE_IRQFLAGS_SUPPORT

# BPF (for bpftrace)
scripts/config -e CONFIG_BPF
scripts/config -e CONFIG_BPF_SYSCALL
scripts/config -e CONFIG_BPF_JIT
scripts/config -e CONFIG_BPF_EVENTS
scripts/config -e CONFIG_DEBUG_INFO_BTF

echo "=== Verifying config ==="
scripts/config --state CONFIG_KPROBES
scripts/config --state CONFIG_KPROBE_EVENTS
scripts/config --state CONFIG_FUNCTION_TRACER
```
