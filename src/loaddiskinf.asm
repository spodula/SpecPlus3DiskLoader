;**********************************************
; This will load a given file to the given location from the
; current default disk.
; Note, this always assume page 0 in $C000 for target.
; On Entry, 
;       HL = filename
;       DE = Max bytes to load
;       BC = Load address
; On Exit,
; Success: c = 0
; Error:   c = error code if any.
;**********************************************

include 'diskloader.i'
include 'system/plusthreedos.i'
include 'system/spectrum128.i'

org $6C00
LOADSINGLEFILE:
    push de
    push bc
    push hl

    call ld_PORT_DOS

    ld bc,$0101     ;file handle=1, access mode=exclusive-read (1)
    ld de,$0001     ;Create=Error if doesnt exist, open=open file, pos aft head
    pop hl
    call DOS_OPEN
    jr c,file_openned ;If not errored, skip
    pop de
    pop de
    ld (err),a        ;Set the error marker
    jr load_done      ;and exit

file_openned:    
    ld bc,$0100      ;file handle=1, target page 0
    pop hl
    pop de
    call DOS_READ
;Going to ignore the error as it either works, or we dont care.

    ld b,$01        ;file handle=1
    call DOS_CLOSE

    xor a
    ld (err),a

load_done:
    call ld_PORT_NORMAL
    ld b,0
    ld a,(err)
    ld c,a
    ret                 

;*****************************************************************
;Variables and constants
;*****************************************************************
err:
    defb $0

;*****************************************************************
;*****************************************************************
ld_PORT_DOS:
     di                  ;
     ld   bc,PORT_MEM1   ;the horizontal ROM switch/RAM switch I/O address
     ld   a,(BANKM)      ;system variable that holds current switch state
     res  4,a            ;move right to left in horizontal ROM switch (3 to 2)
     or   7              ;switch in RAM page 7
     ld   (BANKM),a      ;must keep system variable up to date (very important)
     out  (c),a          ;make the switch
     ei                  ;interrupts can now be enabled
     ret
;*****************************************************************
;*****************************************************************
ld_PORT_NORMAL:
     di                  ;
     ld   bc,PORT_MEM1   ;I/O address of horizontal ROM/RAM switch
     ld   a,(BANKM)      ;get current switch state
     set  4,a            ;move left to right (ROM 2 to ROM 3)
     and  $F8            ;also want RAM page 0
     ld   (BANKM),a      ;update the system variable (very important)
     out  (c),a          ;make the switch
     ei
     ret
   
