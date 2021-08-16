#ifndef KERNEL_H
#define KERNEL_H

#define VGA_WIDTH 80
#define VGA_HIGHT 20

// Mainfunction of the kernel, gets calles by bootloader after switching in real mode
// All initialisations functions gets called
// After this functions is done the OS goes in an infinite loop
void kernel_main();

// Prints an string (as char[]) to terminal
void print(const char* str);

#endif