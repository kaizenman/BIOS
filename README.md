# BIOS
Custom BIOS

# How to build
gcc -c -m16 -o bios.o bios.s
ld -m elf_i386 -T linker.ld -o bios.bin bios.o

# How to debug in 16 bit real mode
https://stackoverflow.com/questions/62513643/qemu-gdb-does-not-show-instructions-of-firmware

## Run qemu with gdb server 
qemu-system-i386 -bios bios.bin -device VGA,romfile="" -s -S

## Run gdb
gdb -ix gdb_init_real_mode.txt -ex 'set tdesc filename target.xml' -ex 'target remote localhost:1234'
