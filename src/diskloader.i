;**********************************************
;General system defines.
;**********************************************


;**********************************************
; diskload.asm
;**********************************************
CHARSET:             equ $3C00 ;Location of the character set bitmap - $100
                           ;Using the default rom set as we're boring.
ITEM_UNSELECTED:     equ 00111000b  ;paper 7, ink 0
ITEM_SELECTED:       equ 00101000b  ;paper 5, ink 0
HEADER_ATTR:         equ 01000111b  ;paper 0, ink 7, bright 1
DEFAULT_ATTR:        equ 00111000b  ;Paper 7, ink 0, 
INFOHEADER_ATTR:     equ 01001111b  ;Paper 1, ink 7, bright 1
INFODATA_ATTR:       equ 00110000b  ;paper 6, ink 0
KEYBOARD_DELAY:      equ $0800  
LEFT_MARGIN:         equ $09
SCREEN_BUFFER:       equ $6500      ;Buffer when loading screen
DISKINF_START:       equ $8b00      ;Start location for disk.inf
DISKINF_MAX:         equ $7200      ;max size of the disk.inf file Leaving space for basic's stack

;**********************************************
;load.asm
;**********************************************
BOOT_FILE:        equ $6C80  ;Load basic file with HL=filename

;**********************************************
;loaddiskinf.asm
;**********************************************
LOAD_SINGLE_FILE:    equ $6C00

;**********************************************
;diskcat.asm
;**********************************************
catbuff:             equ $7100 ; Buffer (Sized for 512 entries)
filecount:           equ $70FE ; Count of files in the buffer
DosError:            equ $70FD ; Any error returned by DOS
do_cat:              equ $7000 ; CAT routine

;**********************************************
;Keyboard.asm
;**********************************************
GetNextChar:         equ $6F68 ; Get the next character from the buffer
KeyboardInterrupt:   equ $6F8A ; Do they keyboard fetch
ResetKeyboardBuffer: equ $6F83 ; Clear keyboard buffer
LastKeyPressed:      equ $6D83 ; Last key pressed variable
GetRawKeyboard:      equ $6F0C ; Get the raw keycode being pressed
            


