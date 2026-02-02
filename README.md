# Schwifty Kernel

A kernel written in Swift.

We chose Swift because, objectively speaking, it is the best programming language when it comes to abstraction, flexibility, memory safety, performance, productivity, and syntax.

## Table of Contents

- [Purpose](#Purpose)
- [Prerequisites](#prerequisites)
- [Status](#status)

## Purpose

The main purpose of this project is to provide memory safety at the kernel level while not sacrificing system performance or developer productivity; we would like it to be a drop-in replacement for existing kernels to make them more secure and performant.

## Prerequisites

- x86 architecture
- assembler (as)
- linker (ld)
- bash
- grub (+libisoburn, mtools, dosfstools)
- QEMU
- Swift 6.2 toolchain

## Status

The project is currently in heavy development, with many components missing or not fully developed.

### Architectures

We have to manually write the boot sequences in assembly for each architecture we want to support, which is why x86 is the only one supported right now; Swift code automatically translates to many architectures so we only need to work on booting for other architectures to fully support them (in theory).

- [x] x86
- [ ] ARM
- [ ] RISC-V
- [ ] WASM

### Drivers

- [x] UART (Serial Port)
- [ ] VGA
- [ ] I/O
  - [ ] Synchronous I/O
  - [ ] Shared Rings (Ring Buffers)
  - [ ] `io_uring`
- [ ] Keyboard
- [ ] Network
- [ ] Virtual I/O
- [ ] Mouse
- [ ] NVME
- [ ] Audio

### Misc

- [x] Protected Mode
- [x] Long Mode
- [x] Global Descriptor Table
- [x] Interrupt Descriptor Table
- [ ] SIMD support
- [ ] Single Address Space (SASOS)
- [ ] APIC (Advanced Programmable Interrupt Controller)
- [ ] Schedulers
- [ ] Cooperative Scheduling
- [ ] Threads
- [ ] Context Switches
- [ ] Processes
- [ ] Swift Runtime
- [ ] Package Traits to only use what you need