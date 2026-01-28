# Schwifty Kernel

A kernel written in Swift.

We chose Swift because, objectively speaking, it is the best programming language when it comes to abstraction, flexibility, memory safety, performance, productivity, and syntax.

## Table of Contents

- [Purpose](#Purpose)
- [Prerequisites](#prerequisites)
- [Status](#status)

## Purpose

The main purpose of this project is to provide memory safety at the kernel level while not sacrificing system performance or developer productivity; we would like it to be a drop-in replacement to existing kernels to make systems more secure and performant.

## Prerequisites

- x86_64 architecture
- QEMU
- Swift 6.2.3 toolchain

## Status

The project is currently in heavy development, with many components missing or not fully developed.

### Architectures

We have to manually write the boot sequences in assembly for each architecture we want to support, which is why x86_64 is the only one supported right now; Swift code automatically translates to many architectures so we don't need to worry about it.

- [x] x86_64
- [ ] ARM
- [ ] RISC-V
- [ ] WASM

### Heap

- [x] Basic implementation
- [ ] Thread-safe
- [ ] Growable
- [ ] Pages
- [ ] Fragmentation fix
- [ ] Graceful failure
- [ ] Virtual Memory
- [ ] ~O(1) allocation complexity

### Drivers
- [x] VGA
- [ ] I/O
  - [ ] Synchronous I/O
  - [ ] Shared Rings (Ring Buffers)
  - [ ] `io_uring`
- [ ] UART (Serial Port)
- [ ] Keyboard
- [ ] Network
- [ ] Virtual I/O
- [ ] Mouse
- [ ] NVME

### Misc

- [ ] Interrupts
- [ ] PIT (Programmable Interval Timer)
- [ ] Schedulers
- [ ] Threads
- [ ] Context Switches
- [ ] Processes
- [ ] Swift Runtime