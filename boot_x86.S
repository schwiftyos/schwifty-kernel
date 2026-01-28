# Multiboot constants
.set ALIGN,    1<<0             # align loaded modules on page boundaries
.set MEMINFO,  1<<1             # provide memory map
.set FLAGS,    ALIGN | MEMINFO  # Multiboot 'flag' field
.set MAGIC,    0x1BADB002       # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS) # checksum of above, to prove we are multiboot

# Multiboot header
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Kernel Entry Point
.section .text
.global _start
_start:
	# set up the stack
	mov $stack_top, %esp

    # align ESP to 16 bytes
    and $-16, %esp   
    
    # subtract 12 bytes 'cause the 'call' below will push 4 bytes (return address); 12 + 4 = 16. This ensures kmain starts with a 16-byte aligned stack
    sub $12, %esp    

    push %ebx # Multiboot info
    push %eax # Magic number

	# call the Swift entry point
	call kmain
1:	hlt
	jmp 1b

.global cpu_halt
cpu_halt:
	hlt
	ret

# Standard I/O port helpers
.global outb
outb:
    mov 4(%esp), %dx # port
    mov 8(%esp), %al # value
    out %al, %dx
    ret

.global inb
inb:
    mov 4(%esp), %dx # port
    in %dx, %al
    ret

# Reserve stack space (16KB)
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top: