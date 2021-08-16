#ifndef IDT_H
#define IDT_H

#include <stdint.h>

struct idt_desc
{
    uint16_t offset_1;  // Offset bit 0-15
    uint16_t selector;  // Selector thats in our GDT
    uint8_t zero;       // Unused set of 0
    uint8_t type_attr;  // Descriptor of type and attributes
    uint16_t offset_2;  // Offset bit 16-31
} __attribute__((packed));

struct idtr_desc
{
    uint16_t limit; // Size of descriptot rable -1
    uint32_t base;  // Base Address of the start of  the interrupt descriptort table
} __attribute__((packed));

// Initializes interrupt descriptor table
// Sets up the idt and sets all implemented interrupts
// Initializes all unimpemented interrupst with no interrupt
void idt_init();

// Triggers enable interrupt asm function
void enable_interrupts();

// Triggers clear interrupt asm function
void disable_interrupts();

#endif