.code16       

.global _start

.macro SET_INT_VECTOR int_number, segment, offset
    pushw %ds
    xorw %ax, %ax
    movw %ax, %ds
    movw $\offset, %ax
    movw %ax, \int_number*4
    movw $\segment, %ax
    movw %ax, \int_number*4+2
    popw %ds
.endm

vgabios_int10_handler:
    pushw %es              
    pushw %ds             
    pushaw                
    movw $0xc000, %bx          
    movw %bx, %ds
    // call _int10_func
    popaw
    popw %ds
    popw %es
    iretw

.org 0xF0000
reset:
    // Disable interrupts
    cli

    xorw %ax, %ax
    movw %ax, %ss
    movw $0xFFFF, %sp       

    // Set up data segment register
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    // Enable interrupts
    sti

    call vgabios_init_func   
    call post               
    // call print_a        

    hang:
        hlt                   
        jmp hang             

post:
    ret                 

/* print_a:
    mov $0x0E, %ah            // Print function
    mov $'A', %al             // Print 'A'
    mov $0x00, %bh            // Page number
    mov $0x07, %bl            // Text attribute
    int $0x10                 // Call the int10 vgabios handler

    ret                       // Return to the BIOS
*/

vga_init_vga_card:
    // switch to color mode and enable CPU access 480 lines
    movw $0x3C2, %dx       
    movb $0xC3, %al       
    outb %al, %dx      

    // more than 64k 3C4/04
    movw $0x3C4, %dx    
    movb $0x04, %al    
    outb %al, %dx   
    movw $0x3C5, %dx 
    movb $0x02, %al 
    outb %al, %dx

    addw $2, %sp       
    ret

vga_init_bios_area:
    pushw  %ds
    movw $0x40, %ax  
    movw %ax, %ds

    // init detected hardware BIOS Area
    movw $0x10, %bx   
    movw (%bx), %ax
    andw $0xFFCF, %ax

    // set 80x25 color (not clear from RBIL but usual)
    orw $0x0020, %ax
    movw %ax, (%bx)

    // Just for the first int10 find its children

    // the default char height
    movw $0x85, %bx       
    movb $0x10, %al
    movb %al, (%bx)

    // Clear the screen 
    movw $0x87, %bx      
    movb $0x60, %al
    movb %al, (%bx)

    // Set the basic screen we have
    movw $0x88, %bx         
    movb $0xf9, %al
    movb %al, (%bx)

    // Set the basic modeset options
    movw $0x88, %bx      
    movb $0x51, %al
    movb %al, (%bx)

    // Set the  default MSR
    movw $0x65, %bx        
    movb $0x09, %al
    movb %al, (%bx)

    popw %ds
    ret




vgabios_init_func:
    // init vga card
    call vga_init_vga_card
    // init basic bios vars
    call vga_init_bios_area

    // set int10 vect
    // TODO:

    pushw %ds
    xorw %ax, %ax
    movw %ax, %ds

    // Assume `vgabios_int10_handler` is defined in the same segment currently pointed by `cs`
    movw %cs, %ax
    movw %ax, 0x10*4+2

    movw $vgabios_int10_handler, %ax
    movw %ax, 0x10*4

    popw %ds



    // SET_INT_VECTOR 0x10, 0xC000, vgabios_int10_handler

    // display splash screen
    // call _display_splash_screen

    // init video mode and clear the screen
    movw $0x0003, %ax
    int $0x10

    // show info
    //call _display_info
    ret

.org 0xFFFF0
_start:
    jmp reset
    // HACK: add 11 zero bytes
    .rept 11
        .byte 0
    .endr

    .word 0xAA55
