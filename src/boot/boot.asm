ORG 0x7C00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
  jmp short init
  nop

times 33 db 0

init:
  jmp 0:start

start:
  cli ; Clear Interupts

  ; set segmat Registers
  mov ax, 0x00
  mov ds, ax
  mov es, ax

  ; set stack Register
  mov ss, ax
  mov sp, 0x7C00

  sti ; Enable Interupts

.laod_protected:
  cli
  lgdt[gdt_descriptor] ; load Global/Interrupt discriptor table
  mov eax, cr0
  or eax, 0x01
  mov cr0, eax
  jmp CODE_SEG:load32
  

;DGT
gdt_start:
gdt_null:
  dd 0x00
  dd 0x00

;offset 0x08
gdt_code:       ; CS SHOULD POINT TO THIS
  dw 0xffff     ; Segment limit bit 0-15
  dw 0x0000     ; Base bit 0-15
  db 0x00       ; Base bit 16-23
  db 0x9A       ; Access byte
  db 0b11001111 ; Flag byte
  db 0x00       ; Base bit 24-31

;offset 0x10
gdt_data:       ; DS, SS, ES, FS, GS
  dw 0xffff     ; Segment limit bit 0-15
  dw 0x0000     ; Base bit 0-15
  db 0x00       ; Base bit 16-23
  db 0x92       ; Access byte
  db 0b11001111 ; Flag byte
  db 0x00       ; Base bit 24-31

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1
  dd gdt_start

[BITS 32]
load32:
  mov eax, 1
  mov ecx, 100
  mov edi, 0x0100000
  call ata_lba_read
  jmp CODE_SEG:0x0100000

ata_lba_read:
  mov ebx, eax ; Backup the LBA
  ; Send the highest 8 bits of the lba to hard disk controller
  shr eax, 24
  or eax, 0xE0 ; select master drive
  mov dx, 0x1F6
  out dx, al
  ; Finished sending the highest 8 bits of the lba
  
  ; send the total sectors to read
  mov eax, ecx
  mov dx, 0x1F2
  out dx, al
  ; finished sending the total sectors to read

  ; Send more bits of the LBA
  mov eax, ebx ; restore LBA backup
  mov dx, 0x1F3
  out dx, al
  ; Finished sending more bits of the LBA

  ; Send more bits of the LBA
  mov eax, ebx ; restore LBA backup
  mov dx, 0x1F4
  shr eax, 8
  out dx, al
  ; Finished sending more bits of the LBA

  ; Send upper 16 bits of the LBA
  mov eax, ebx ; restore LBA backup
  mov dx, 0x1F5
  shr eax, 16
  out dx, al
  ; Finished sending upper 16 bits of the LBA

  mov dx, 0x1F7
  mov al, 0x20
  out dx, al

  ; Read all sectors into memory
.next_sector:
  push ecx

  ; Checking if we need to read
.try_again:
  mov dx, 0x1F7
  in al, dx
  test al, 8
  jz .try_again

  ; read 256 words at a time (needet)
  mov ecx, 256
  mov dx, 0x1F0
  rep insw
  pop ecx
  loop .next_sector
  ;end of reading sectors int memory
  ret

times 510-($ - $$) db 0
dw 0xAA55
