#ifndef IO_H
#define IO_H

// Reads one byte from the specified bus port
unsigned char insb(unsigned short port);

// Reads two bytes from the specified bus port
unsigned short insw(unsigned short port);


// Writes one byte to the specified bus port
void outb(unsigned short port, unsigned char val);

// Writes two bytes to the specified bus port
void outw(unsigned short port, unsigned short val);

#endif