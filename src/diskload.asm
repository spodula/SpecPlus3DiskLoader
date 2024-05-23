;***************************************************
; Disk loader for Spectrum +3 disks
; This is a relatively simple selection and loader.
; Is does a CAT of all the *.bas files and 
;***************************************************
include 'diskloader.i'

ORG $6700
    ld (tempSP),sp      ;Preserve Basics stack
    ld sp,$66ff

;Clear the screen
    ld hl,$5800
    ld de,$5801
    ld bc,$02ff
    ld (hl),DEFAULT_ATTR
    ldir

    ld hl,$4000
    ld de,$4001
    ld bc,$17ff
    ld (hl),0
    ldir

;Clear the data cache
    ld hl,DISKINF_START
    ld de,DISKINF_START+1
    ld bc,DISKINF_MAX-1
    ld (hl),'$'
    ldir

;Border 7
    ld a,7
    out ($fe),a

;Top line
    call display_message_inline
    defb HEADER_ATTR,$0,$0," SELECT FILE TO LOAD            ",$FF

    ld de,$001a
    call DisplayStripe

;Load directory listing of all .bas files.
    call display_message_inline
    defb DEFAULT_ATTR,$0e,$0,"Loading...",$FF
    
    call do_cat   

    ld hl,STRING_DISKINF
    ld de,DISKINF_MAX
    ld bc,DISKINF_START
    call LOAD_SINGLE_FILE

    call display_message_inline
    defb DEFAULT_ATTR,$0e,$0,"          ",$FF

;convert the"*" to $FF in the diskinf buffer
    ld hl,DISKINF_START
convert_nextchr:
    ld a,(hl)
    cp '*'
    jr nz,convert_dontupdate
    ld (hl), $FF
convert_dontupdate:
    inc hl
    xor a
    cp h
    jr nz, convert_nextchr

;Display a vertical seperator line.
    ld de,$0108
    ld b,ITEM_UNSELECTED
    call DisplayVerticalLine

;Select first file.
    ld hl,$0000
    ld (FileSelectorStart),hl
    call UpdateFileList    
    
;***************************************************
; Main loop
;***************************************************
cmd_loop:    
;Update the currently selected file.
    ld a,1
    ld (updateRequired),a
    call UpdateSelection

key_loop:
;delay for a bit
    ld bc,KEYBOARD_DELAY
delay_loop:
    dec bc
    ld a,b
    or c
    jr nz,delay_loop

;keyboard
    call KeyboardInterrupt
    call GetNextChar
    cp 0                    ;Nothing selected?
    jr z,DoUpdateIfRequred  ;Check to see if update is required.

    cp $10                  ;Down arrow
    jp z,move_down
    cp $11                  ;Up arrow
    jp z,move_up                
    cp "'"                  ;Up arrow with Symbol shift
    jp z,nextpageup
    cp '&'                  ;Down arrow with Symbol shift
    jp z,nextpagedown       
    cp $0d                  ;Return button
    jp z,do_select
    cp 'a'
    jp c, key_loop          ;Loop back for more.
    cp 'z'
    jp nc, key_loop         ;Loop back for more.

;a-z pressed
    res 5,a                 ; uppercase
;try to locate in disk cat buffer
    ld c,a                  ; preserve key      
    ld hl,$0000             ; start number of the list
    ld ix,catbuff+13        ; Cat buffer - ignoring first blank entry
ksearchloop:
    ld a,(ix+0)             ; End of catbuf?
    cp 0                    
    jp z,key_loop           ; If we run out of entries, skip out
    cp c                    ; Compare with key
    jr nc,ksl_foundentry    ; If current entry >= key, go there
    inc hl                  ; next entry
    ld de,13                ; next entry in catbuf
    add ix,de
    jr ksearchloop          ; go back for another go.
    
ksl_foundentry:
; We have found the matching (or next) entry. Go to it.
    ld (FileSelectorStart),hl ;new top of the list
    xor a                     ;Select the top item in the list.
    ld (SelectedItem),a
    call UpdateFileList       ;Update the file list
    jp key_loop               ;Loop back for more.


;*******************************************************
; Update the right side if required.
;*******************************************************
DoUpdateIfRequred:
;If a key is still being pressed, then jump out.
    call GetRawKeyboard     
    cp 0
    jr nz, key_loop

;Do we need to do any update? If not, jump out
    ld a,(updateRequired)
    cp 0
    jr z, key_loop

;We are doing the update, so reset the update required flag.
    xor a
    ld (updateRequired),a

;Clear the side page.
    call clear_sideblock

;Update the program name at the top of the side page.
    call display_message_inline
    defb INFOHEADER_ATTR,$01,LEFT_MARGIN,"Program:               ",$FF

;Display filename
    call GetSelectedItemPtrFromBuffer       ;Filename -> hl
    push hl
    ld de,$0112                ;At 1,18
    ld b,01001101b             ;Bright 1, paper 1(blue), ink 5 (Cyan)
    ld c,8                     ;8 characters
    call display_message_len
    pop hl

; Now the information page
    call locateInfoData
    push de
    pop hl

    ld d,0
    ld e,LEFT_MARGIN
    add hl,de
    push hl

    ld d,3
    ld e,LEFT_MARGIN
    ld hl,STRING_NAME
    ld b,INFOHEADER_ATTR
    call display_messag_wrap
    pop hl
    ld b,INFODATA_ATTR
    ld c,LEFT_MARGIN
    call display_messag_wrap
;newline
    ld e,LEFT_MARGIN
    inc d
;Publisher
    push hl
    ld hl,STRING_PUBLISHER
    ld b,INFOHEADER_ATTR
    call display_messag_wrap
    pop hl
    ld b,INFODATA_ATTR
    call display_messag_wrap
;newline
    ld e,LEFT_MARGIN
    inc d
    push hl
;Year
    ld hl,STRING_YEAR
    ld b,INFOHEADER_ATTR
    call display_messag_wrap
    pop hl
    ld b,INFODATA_ATTR
    call display_messag_wrap
;newline
    ld e,LEFT_MARGIN
    inc d
    inc d
    push hl
    ld hl,STRING_NOTES
    ld b,INFOHEADER_ATTR
    call display_messag_wrap

    call DisplayHorizontalLine
    inc d
    ld e,LEFT_MARGIN

    ld b,INFODATA_ATTR
    pop hl
    call display_messag_wrap

    inc d
    ld e,LEFT_MARGIN

;go back to keyboard loop
    jp key_loop
          
;*******************************************************
; Clear the side-block.
;*******************************************************
clear_sideblock:
    ld de,$0209     ;Start At 2,9

csb_vloop:
    push de
csb_hloop:
    ld b,INFODATA_ATTR  ;Attribute = ink 0 (black), paper 6 (Yellow)
    ld hl,csb_space ;SPACE
    push de         ;preserve X/Y
    call DisplayUDG ;Write space
    pop de          ;Get back X/Y
    inc e           ;Next character
    ld a,$20        ;EOL?
    cp e
    jr nz,csb_hloop ; No, next character
    pop de          ;Get back X/Y
    inc d           ;Next line
    ld a,$18        ;End of screen?
    cp d            
    jr nz,csb_vloop ;No, go back.

    ret

;*******************************************************
;Called when a file is selected. Try to load the file.
;*******************************************************
do_select:  
;Get the filename address from the cache
    call GetSelectedItemPtrFromBuffer

;Now copy (up to) the first 8 bytes of the filename to FILENAMEBUFFER
    ld DE,FILENAMEBUFFER    ;Temp filename buffer
    ld b,8                  ;Up to 8 characters
doselectloop:
    ld a,(hl)               ;get character.
    cp 0                    ;End of line?
    jr z,doselect_skiploop  ;If so, next bit
    ld (de),a               ;Write character
    inc hl                  ;Next character
    inc de
    djnz doselectloop       ;And again.

;From here, we need to add in the ".BAS"
doselect_skiploop:
    ld hl,STRING_DOTBAS     ; Pointer to the ".BAS"
    ld bc,$0005             ; 4 bytes long
    LDIR                    ; copy the 4 bytes from DOTBAS to DE   

    ld sp,(tempSP)          ; Get back the original stack.

    LD HL,FILENAMEBUFFER    ; Now try to load this file.
    jp BOOT_FILE   

;*******************************************************
;Move up the list.
;*******************************************************
move_up:
    ld a,(SelectedItem)
    dec a
    cp $ff                  ;Rolled over?
    jr z,nextpageup         ;Yes, go up a page.

    ld (SelectedItem),a     ;write back new item
    jp cmd_loop             ;Loop back
nextpageup:
    ld hl,(FileSelectorStart)   ;Check if we are at the top of the list already
    ld a,h
    or l
    jp z,cmd_loop               ;If so, just ignore the keypress
    ld bc,$FFEA                 ;Subtract 22 from the top item ($FFEA = -22)
    add hl,bc
    ld (FileSelectorStart),hl   ;Write back
    call UpdateFileList         ;Update the file list
    ld a,22                     ;Select the bottom item in the list.
    ld (SelectedItem),a
    jp cmd_loop                 ;and go back.

;*******************************************************
;Move down the list.
;*******************************************************
move_down:
    ld a,(SelectedItem)
    inc a
    cp 23                   ; Rolled over?
    jr z,nextpagedown       ; Yes, go down a page

    ld hl,LastInList
    cp (hl)
    jp z,cmd_loop

    ld (SelectedItem),a     ; write back new item
    jp cmd_loop             ; Loop back

nextpagedown:
    ld hl,(FileSelectorStart)
    ld bc,22                    ;Add 22 to the top item
    add hl,bc
    ld (FileSelectorStart),hl   ;Write back
    call UpdateFileList         ;Update the file list
    xor a                       ;Select the top item in the list.
    ld (SelectedItem),a
    jp cmd_loop                 ;and go back.

;*******************************************************
;Update the selection highlighting.
;*******************************************************
UpdateSelection:
    ld a,(LastSelectedItem)      ;Get the last item highlighted
    ld b,ITEM_UNSELECTED         ;unselected attributes
    call SetAttributesForEntry   ;unselect it.
    ld a,(SelectedItem)          ;get the current item highlighted
    ld (LastSelectedItem),a      ;update the last item highlighted
    ld b,ITEM_SELECTED           ;selected attribute
    call SetAttributesForEntry   ;selec it
    ret

;*******************************************************
;Update the attribute highlighting for the given entry
; a = entry number b = attribute
;*******************************************************
SetAttributesForEntry:
    cp 23
    ret nc
    ld e,0
    ld d,a
    inc d
    push bc
    call CalculateAttributeAddress
    pop af
    ld b,8
SAFE_loop:
    ld (hl),a
    inc hl
    djnz SAFE_loop
    ret

;*******************************************************
;Get a pointer to the filename of the currently selected
;item.
;Inputs
;   None
;Returns
;   HL=address
;Corrupts:
;   DE AF
;*******************************************************
GetSelectedItemPtrFromBuffer:
    ld d,0
    ld a,(SelectedItem)
    ld e,a

;*******************************************************
;Calculate the address of the currently selected item
;in the buffer. + BC
;   DE = addition
;Returns
;   HL=address
;Corrupts:
;   DE F
;*******************************************************
GetFilenamePtrFromBuffer:
;Add in the start of the displayed buffer.
    ld hl,(FileSelectorStart)
    add hl,de
    inc hl
;multiply HL by 13
    push hl
    add hl,hl       ;x2
    add hl,hl       ;x4
    push hl
    add hl,hl       ;hl now equals hlx8
    pop de
    add hl,de       ;hl now equals hlx12
    pop de
    add hl,de       ;hl now equals hlx13
;Add in start of buffer
    ld de,catbuff  
    add hl,de
    ret

;*******************************************************
; Update the complete file list.
;*******************************************************
UpdateFileList:
    ld a,23
    ld (LastInList),a
    ld de,0
    call GetFilenamePtrFromBuffer
;Now we have number of files in bc, Start in HL
    ld de,$0100 ;Y/X

updateListLoop:
    push hl
    push de
    push de
    ld a,(hl)
    cp 0
    jr nz,ufl_dontblank
skipupdatell:
    ld a,(LastInList)
    cp 23
    jr nz,DontSetLIL
    ld a,d
    dec a
    ld (LastInList),a
DontSetLIL:
    xor a
    ld hl,STRING_BLANKENTRY
ufl_dontblank:
;Display filename
    pop de
    ld b,ITEM_UNSELECTED
    ld c,8
    push af
    call display_message_len
    pop af
    pop de
    pop hl
    cp 0
    jr z,ufl_dontinc
    ld bc,13
    add hl,bc
ufl_dontinc:
    inc d
    ld a,24
    cp d
    jr nz,updateListLoop

    ret

;*******************************************************
; Display vertical line. DE = yx b=attribute
;*******************************************************
DisplayVerticalLine:
dvl_loop:
    push de
    push bc
    ld hl, dvl_Vline
    call DisplayUDG
    pop bc
    pop de
    inc d
    ld a,d
    cp 24
    jr nz,dvl_loop
    ret

;*******************************************************
; Display horezontal line. DE = yx b=attribute
;*******************************************************
DisplayHorizontalLine:
dhl_loop:
    push de
    push bc
    ld hl, dvl_hline
    call DisplayUDG
    pop bc
    pop de
    inc e
    ld a,e
    cp 32
    jr nz,dhl_loop
    ret

;*******************************************************
; Display Stripe. DE = yx
;*******************************************************
DisplayStripe:
    ld b,5         ;5 stripes
    ld hl,menu_stripe_attributes   
ds_loop:
    push bc
    ld b,(hl)      ;set stripe attribute
    push de
    push hl
    ld hl, menuchr_stripe
    call DisplayUDG
    pop hl
    pop de
    pop bc  
    inc e           ;x=x+1
    inc hl          ;Next set of attributes
    djnz ds_loop
    ret
;**********************************************************
;Display a message of a given length
; HL = message pointer
; b = attribute c = length
; DE = Y/X
;**********************************************************
display_message_len:
    ld a,(hl)           ; get byte
    inc hl              ; (Point to next byte)
    push hl             ; Store character pointer.
    push de
    push bc
    call DisplayASCII
    pop bc
    pop de
    inc e
    pop hl              ; Get back character pointer
    dec c
    jr nz,display_message_len
    ret

;**********************************************************
; Display a message on the screen. 
; first three bytes:
; +0: Attribute byte
; +1: Y
; +2: X
; Message after call, terminated with $FF
;**********************************************************
display_message_inline:
    pop hl              ; Get address of next byte after the CALL
    ld b,(hl)           ; attribute byte
    inc hl
    ld d,(hl)
    inc hl
    ld e,(hl)
    inc hl
    call display_message
dmi_finish:
    jp (hl)             ; Jump back after the $FF.

;**********************************************************
;Display a message
; HL = message pointer ($FF terminates)
; B = attribute
; DE = Y/X
;**********************************************************
display_message:
    ld a,(hl)           ; get byte
    inc hl              ; (Point to next byte)
    cp $FF              ; No more string?
    ret z
    push hl             ; Store character pointer.
    push de
    push bc
    call DisplayASCII
    pop bc
    pop de
    inc e
    pop hl              ; Get back character pointer
    jr display_message        ; Next character


;**********************************************************
;Display a message
; HL = message pointer ($FF terminates)
; B = attribute
; C = start
; DE = Y/X
;**********************************************************
display_messag_wrap:
    ld a,(hl)           ; get byte
    inc hl              ; (Point to next byte)
    cp $FF              ; No more string?
    ret z
    cp ']'
    ret z
    push hl             ; Store character pointer.
    push de
    push bc
    call DisplayASCII
    pop bc
    pop de
    inc e
    ld a,$20
    cp e
    jr nz,display_messagdontwrap
    ld e,c
    inc d
display_messagdontwrap:
    pop hl              ; Get back character pointer
    jr display_messag_wrap        ; Next character
;**********************************************************
; Display an ascii character A at DE B = attribute
; or 
;Display a UDG, where HL= address of chartacter, DE=XY, B=attr 
;**********************************************************
DisplayUDG:
    push bc
    push de
    jr DisplaySkipAddrCalc

DisplayASCII:
    push bc
    push de   
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld bc, CHARSET
    add hl,bc
DisplaySkipAddrCalc:
    push hl
    call LineToAddress       ; Convert DE to a line address
    pop de
;Write the character
    ld b,8                   ; 8 lines                 
displayBlockLoop:   
    ld a,(de)                ; source
    ld (hl),a                ; target
    inc de                   ; next source address
    inc h                    ; next target line
    djnz displayBlockLoop    ; next character

;Set the attribute to Black on white.
    pop de                 ;Get back X,Y
;Calculate address
    call CalculateAttributeAddress
;Set attribute
    pop bc
    LD (hl),b
    
    ret
;**********************************************************
;* Calculate the address of the attribute block
;* 
;* D=Character line no e=character
;* return HL=address
; AF,BC corrupt
;**********************************************************
CalculateAttributeAddress:
    ld l,d      ;d(y) -> HL
    ld h,0
    add hl,hl   ;hl = hl *32
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld b,$58    ;Add in $5b00 and the Line character (e)
    ld c,e
    add hl,bc
    ret

;**********************************************************
;* Calculates the address of a character line
;* 
;* D=Character line no e=character
;* return HL=address
;* AF, HL corrupt
;*
;* Address: 010A A000 BBBY YYYY
;* Where X=000AABBB 
;**********************************************************
LineToAddress:
    ld a,d      ;Mask out "AA"
    and $18
    or $40      ;Add in $040
    ld h,a      ;This put 010AA000 into H

    ld a,d      ; Move "BBB" to the last 3 bits (shift by 5)
    add a,a
    add a,a
    add a,a
    add a,a
    add a,a
    and $e0     ; Mask out any rubbish
    or e        ; Mask in the Y value.
    ld l,a      ; and L is the LSB.
    ret    

;*******************************************************
;Locate file data
;HL = address of selected filename
;*******************************************************
locateInfoData:
    ld de,DISKINF_START    
lid_loop:
    ld a,(de)
    cp '$'
    jr z,lid_blank

    ld b,8
    push hl
    push de
checkfileloop:
    ld a,(de)    
    cp (hl)
    jr nz,nextentry
    inc de
    inc hl
    djnz checkfileloop
;if we have got here, we have a match, so return.
    pop de
    pop hl
    ret

lid_blank:
    ld de,BLANK_DATA
    ret

nextentry:
    pop hl
    pop hl

nextentryloop:
    ld a,(de)  
    inc de
    cp ']'
    jr z,skipcr
    cp '$'          ;end of file marker?
    jr z,lid_blank
    jr nextentryloop
skipcr:
    ld a,(de)
    cp $0d
    jr nz,notcr
    inc de
    jr skipcr
notcr:
    cp $0a
    jr nz,lid_loop
    inc de
    jr skipcr

;*******************************************************
;Variables / Constants.
;*******************************************************
updateRequired:
    defb $0         ;Update required flag. if 1, an update is required for right 
FILENAMEBUFFER:
    defb "12345678.123",$0 ;Buffer for the filename to load.
FileSelectorStart:
    defw $0000      ;Start location of the display
SelectedItem:
    defb $0         ;Currently selected entry indexed from FileSelectorStart
LastSelectedItem:
    defb $ff        ;Last selected item. Used as part of determining if update
LastInList:
    defb $00        ;Last valid item in the current list.
tempSP:
    defw $0000      ;temporary basic stack.

menuchr_stripe:     ;Definition for the Strip at the top
    defb 00000001b
    defb 00000011b
    defb 00000111b
    defb 00001111b
    defb 00011111b
    defb 00111111b
    defb 01111111b
    defb 11111111b

dvl_Vline:          ;Vertical line 
    defb 00011000b
    defb 00011000b
    defb 00011000b
    defb 00011000b
    defb 00011000b
    defb 00011000b
    defb 00011000b
    defb 00011000b

dvl_hline:
    defb 00000000b
    defb 00000000b
    defb 00000000b
    defb 11111111b
    defb 11111111b
    defb 00000000b
    defb 00000000b
    defb 00000000b

csb_space:          ;Space for blanking
    defb 00000000b
    defb 00000000b
    defb 00000000b
    defb 00000000b
    defb 00000000b
    defb 00000000b
    defb 00000000b
    defb 00000000b

menu_stripe_attributes: 
;        FBPPPIII   where F=Flash. B=Bright, PPP=paper, III=Ink
    defb 01000010b  ;Paper black  (000) ink Red    (010)
    defb 01010110b  ;Paper Red    (010) ink Yellow (110)
    defb 01110100b  ;Paper Yellow (110) ink Green  (100)
    defb 01100101b  ;Paper Green  (100) ink Cyan   (101)
    defb 01101000b  ;Paper Cyan   (101) ink Black  (000)

BLANK_DATA:
    defb "         ",$FF,$FF,$FF,"]"
STRING_NAME:
    defb "Name:",$FF
STRING_PUBLISHER:
    defb "Publ:",$FF
STRING_YEAR:
    defb "Year:",$FF
STRING_NOTES: 
    defb "Notes:                 ",$FF
STRING_DISKINF:
    defb "DISK.INF",$FF      ;the file name, must be terminated with FFh
STRING_DOTBAS:         
    defb ".BAS",$00 ;Constant ".BAS" to append to filename
STRING_BLANKENTRY:     
    defb "        " ;One blank entry. Used when we have run out of files.


