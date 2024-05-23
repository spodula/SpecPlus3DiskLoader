;**********************************************
;Load the given file (BASIC file only)
; HL = filename
;
;This is basically a copy of the first
;few bytes from the "load DISK" code from Rom 1. 
;It will return if it fails, otherwise wont return.
; This will work, but is probably not ideal.
;**********************************************
org $6C80

include "system/spectrum128.i"

;*************************************************
; Load the given null terminated file. 
; This code expects Rom 3 (48K rom) paged.
;
; On entry, 
;   HL = filename (null terminated)
; On successful load, wont return. 
; On error, will return to basic
;*************************************************

BOOT_FILE:  

;Initially, we need to create a command buffer containing
;the tokens for load "filename"
        ld de,LOADDISK+2        ;Start after $EF,$22 (load ")
        ld c,2                  ;setup Count of command length.
nextchar:
        ld a,(hl)               ;get character
        cp 0                    ;end?
        jr z,finishedcopy       ;if so, finish
        ld (de),a               ;copy character
        inc hl                  ;next character
        inc de                  ;next in buffer
        inc c                   ;add 1 to command length
        jr nextchar             ;back for next one
finishedcopy:
        ld a,$22                ;add in final quote
        ld (de),a
        inc c                   ;and add 1 to command length
        ld b,0                  ;set b to 0 so bc=command length.
        push bc                 ;store for later

;Clear editing workspace
        call $16b0		

;allocate space for load "xxx" command in the workspace (BC=length)
        ld hl,(E_LINE)          ; location to create space (Current edit line address)
        pop bc                  ; back back command length
        push bc
        call $1655		        ; create BC bytes of space at E_LINE

;Copy command to the newly allocated space.
        ld hl,LOADDISK          ; created command
        ld de,(E_LINE)          ; Target in the workspace
        pop bc                  ; command length
        ldir    		        ; copy LOAD "filename" into E_LINE

;page in rom 1 as we want to use the 128K parser to run the command.        
        di
        ld a, (BANK678)
        res 2,a
        ld (BANK678),a
        ld bc,PORT_MEM2
        out (c),a
        ei

;Setup execution environment
        ld      hl,(E_LINE)     ; set next character to be interpreted to our workspace
        ld      (CH_ADD),hl	    

        res     6,(iy+$02)	    ; TVFLAGS: signal "lower screen can be cleared"
        set     7,(iy+$01)	    ; FLAGS: signal "execution mode"
        ld      (iy+$0a),$01	; PPC: Statement in line: 1
        ld      hl,$3e00        ;
        push    hl
        ld      hl,ONERR        ;Error return
        push    hl
        ld      (ERRSP),sp	; set up error stack
        ld      hl,ERRORRETURN; dos error

        ld      (SYNRET),hl	; error return address
        jp      $1048		; execute the edit line, returning here on error

ERRORRETURN:
        ld sp,(ERRSP)       ; get back stack 
        jp $25cb            ; Return to basic via standard error return
        
LOADDISK:
    	defb	$ef		; LOAD keyword
        defb    $22,"xxxxxxxx.xxx",$22

