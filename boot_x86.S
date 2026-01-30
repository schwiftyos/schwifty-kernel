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

# GS
.global load_gs
load_gs:
    mov 4(%esp), %ax # load the GDT Selector (e.g., 0x18)
    mov %ax, %gs
    ret

# Return the CR0 register (to check the bit modes)
.global get_cr0
get_cr0:
    mov %eax, %cr0
    ret

# Read Extended Feature Enable register (to check for "Long Mode")
.global read_efer
read_efer:
    mov %ecx, 0xC0000080 # EFER MSR address
    rdmsr                # Reads MSR into EDX:EAX
    ret

# Return the Code Segment register (to check privilege level)
.global get_cs
get_cs:
    mov 0, %eax
    mov %cs, %ax 
    ret

# Context switch
.global context_switch
context_switch:
    # save current thread's state
    push %ebp
    push %ebx
    push %esi
    push %edi

    # switch stacks
    mov 20(%esp), %eax # pointer to old_stack_ptr
    mov %esp, (%eax)   # save current ESP
    mov 24(%esp), %eax # new stack pointer
    mov %eax, %esp     # load new ESP

    # restore new thread's state
    pop %edi
    pop %esi
    pop %ebx
    pop %ebp
    ret

# Read rdrand
.global read_rdrand
read_rdrand:
    rdrand %eax
    jnc read_rdrand # try again if CF=0 (the hardware was busy)
    ret

# rdtsc
.global rdtsc
rdtsc:
    rdtsc # loads EDX:EAX with the 64-bit timestamp
    ret   # Swift will read EAX (the lower 32 bits)

# Reserve stack space (16KB)
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top: