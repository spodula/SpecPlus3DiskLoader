;*****************************************************************
; Do a catalog of all the .BAS files and place the data in catbuf
; This has been extended from the example in the +3 Manual
; to handle case of >64 entries (Much more likely on HDDs)
;*****************************************************************

include 'diskloader.i'
include 'system/plusthreedos.i'
include 'system/spectrum128.i'
org $7000

;*****************************************************************
; This was basically copied from the example the +3 Manual
; with now a lot of modifications.
;*****************************************************************
DO_CAT:
;  Page in +3DOS
    call dc_PORT_DOS

;reset file count.
     ld bc,0000          ;set the buffer counter to zero.
     ld (filecount),bc

;Clear the buffer.
     ld   hl,catbuff     ;
     ld   de,catbuff+1   ;
     ld   bc,$1A00       ; (512 13 byte entries = 6656 bytes = $1A00)
     ld   (hl),0
     ldir                ;make sure at least first entry is zeroised


;Do the cat
     ld   de,catbuff     ;the location to be filled with the disk catalog
cat_again:
     ld   b,255          ;the number of entries to get in this pass.
     ld   c,0            ;dont include system files in the catalog
     ld   hl,stardotbas  ;the file name ("*.bas")
     push de
     call DOS_CATALOG    ;call the DOS entry
     pop  de

;Check for error codes and jump out if we have errored.
     ld (DosError),a     ;put it where it can be seen from BASIC    
     jr nc,cat_done

;Add in the new count of files 
     push bc             ;preserve number of files added
     ld hl,(filecount)   ;Get file number count
     ld c,b              ; B-> bc
     ld b,0
     dec c               ;Remove initial file.
     add hl,bc          
     ld (filecount),hl   ;Update number of files
     pop bc

;See if we reached the end of cat
     ld a,255            ;if we have returned less than 255 entries, 
     cp b                ;that should be end.
     jr nz,cat_done 

;next cat location is the last file entry. so return.
     ld hl,13*254        ;add in 254 entries to DE
     add hl,de          
     ex de,hl
     jr cat_again        ;and go again

cat_done:
     call dc_PORT_NORMAL
     ld bc,(filecount)
     ret                 ;return to BASIC, value in BC is returned to USR

stardotbas:
     defb "*.BAS",$FF      ;the file name, must be terminated with FFh

;*****************************************************************
;*****************************************************************
dc_PORT_DOS:
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
dc_PORT_NORMAL:
     di                  ;
     ld   bc,PORT_MEM1   ;I/O address of horizontal ROM/RAM switch
     ld   a,(BANKM)      ;get current switch state
     set  4,a            ;move left to right (ROM 2 to ROM 3)
     and  $F8            ;also want RAM page 0
     ld   (BANKM),a      ;update the system variable (very important)
     out  (c),a          ;make the switch
     ei
     ret

