#!/bin/bash

# Build the project
echo "Building the project..."
gcc -c -m16 -o bios.o bios.s
ld -m elf_i386 -T linker.ld -o bios.bin bios.o
echo "Done!"
