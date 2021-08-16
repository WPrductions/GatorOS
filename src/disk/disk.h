#ifndef DISK_H
#define DISK_H

typedef unsigned int GATOROS_DISK_TYPE;

// Reprisents a real pysical hard disk
#define GATOROS_DISK_TYPE_REAL 0


struct disk
{
    GATOROS_DISK_TYPE type;
    int sector_size;
};

// Searches and intializes all disks
// (Temporarily hardcoded to one disk)
void disk_search_and_init();

// Gets disk by index
// (Temporarily hardcoded to one disk with index 0, all oter indeces will cause an error)
struct disk* disk_get(int index);

// Reads blocks from hard disk in sectors of each 512 bytes
int disk_read_block(struct disk* idisk, int lba, int total, void* buffer);


#endif