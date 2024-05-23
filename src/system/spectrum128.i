;*************************************************************************************
;Spectrum 128 +2B/+3 ROM system variables
;*************************************************************************************
SWAP:       equ $5B00    ; Paging subroutine
STOO:       equ $5B10    ; Paging subroutine. Entered with interrupts already disabled and AF, BC on the stack.
YOUNGER:    equ $5B21    ; Paging subroutine.
REGNUOY:    equ $5B2A    ; Paging subroutine.
ONERR:      equ $5B3A    ; Paging subroutine.
OLDHL:      equ $5B52    ; Temporary register store while switching ROMs.
OLDBC:      equ $5B54    ; Temporary register store while switching ROMs.
OLDAF:      equ $5B56    ; Temporary register store while switching ROMs.
TARGET:     equ $5B58    ; Subroutine address in ROM 3.
RETADDR:    equ $5B5A    ; Return address in ROM 1.
BANKM:      equ $5B5C    ; Copy of last byte output to I/O port 7FFDh (32765)
RAMRST:     equ $5B5D    ; RST 8 instruction. Used by ROM 1 to report old errors to ROM 3.
RAMERR:     equ $5B5E    ; Error number passed from ROM 1 to ROM 3
BAUD:       equ $5B5F    ; RS232 bit period in T states/26. Set by FORMAT LINE.
SERFL:      equ $5B61    ; Second_character_received_flag, and data.
COL:        equ $5B63    ; Current column from 1 to width.
WIDTH:      equ $5B64    ; Paper column width. Defaults to 80.
TVPARS:     equ $5B65    ; Number of inline parameters expected by RS232.
FLAGS3:     equ $5B66    ; Various flags.
BANK678:    equ $5B67    ; Copy of last byte output to I/O port 1FFDh (8189).
XLOC:       equ $5B68    ; Holds X location when using the unexpanded COPY command
YLOC:       equ $5B69    ; Holds Y location when using the unexpanded COPY command
OLDSP:      equ $5B6A    ; Old SP (stack pointer) when TSTACK is in use.
SYNRET:     equ $5B6C    ; Return address for ONERR.
LASTTV:     equ $5B6E    ; Last value printed by calculator.
RCLINE:     equ $5B73    ; Current line being renumbered.
RCSTART:    equ $5B75    ; Starting line number for renumbering. The default value is 10.
RCSTEP:     equ $5B77    ; Incremental value for renumbering. The default is 10.
LODDRV:     equ $5B79    ; Load default drive
SAVDRV:     equ $5B7A    ; Save default drive
DUMPLF:     equ $5B7B    ; Holds the number of 1/216ths user for line feeds in 'COPY EXP'
STRIP1:     equ $5B7C    ; Stripe one bitmap.
STRIP2:     equ $5B84    ; Stripe two bitmap. 
TSTACK:     equ $5BFF    ; Temporary stack grows down from here. Used when RAM page 7 is switched in at top of memory

KSTATE:		equ	$5C00    ; Used in reading the keyboard
LAST_K:		equ	$5C08    ; Last key pressed
REPDEL:		equ	$5C09    ; Time that a key must be held down before it repeats
REPPER:		equ	$5C0A    ; Delay between successive repeats of a key held down
DEFADD:		equ	$5C0B    ; Address of arguments of user defined function
K_DATA:		equ	$5C0D    ; Second byte of colour controls entered from keyboard
TVDATA:		equ	$5C0E    ; Colour,  AT and TAB controls going to television 
STRMS:		equ	$5C10    ; Addresses of channels attached to streams
CHARS:		equ	$5C36    ; 256 less than address of character set
RASP:		equ	$5C38    ; Length of warning buzz
PIP:		equ	$5C39    ; Length of keyboard click
ERR_NR:		equ	$5C3A    ; One less than the error report code
FLAGS:		equ	$5C3B    ; Various flags to control the BASIC system
TV_FLAG:	equ	$5C3C    ; Flags associated with the television
ERRSP:		equ	$5C3D    ; Address of item on machine stack to use as error return
LISTSP:	    equ	$5C3F    ; Return address from automatic listing
MODE:		equ	$5C41    ; Specifies K,L,C,E or G cursor
NEWPPC:		equ	$5C42    ; Line to be jumped to
NSPPC:		equ	$5C44    ; Statement number in line to be jumped to
PPC:		equ	$5C45    ; Line number of statement being executed
SUBPPC:		equ	$5C47    ; Number within line of statement being executed
BORDCR:		equ	$5C48    ; Border colour
E_PPC:		equ	$5C49    ; Number of current line
VARS:		equ	$5C4B    ; Address of variables
DEST:		equ	$5C4D    ; Address of variable in assignment
CHANS:		equ	$5C4F    ; Address of channel data
CURCHL:		equ	$5C51    ; Address of information used for input and output
PROG:		equ	$5C53    ; Address of BASIC program
NXTLIN:		equ	$5C55    ; Address of next line in program
DATADD:		equ	$5C57    ; Address of terminator of last DATA item
E_LINE:		equ	$5C59    ; Address of command being typed in
K_CUR:		equ	$5C5B    ; Address of cursor
CH_ADD:		equ	$5C5D    ; Address of the next character to be interpreted
X_PTR:		equ	$5C5F    ; Address of the character after the '?' marker
WORKSP:		equ	$5C61    ; Address of temporary work space
STKBOT:		equ	$5C63    ; Address of bottom of calculator stack
STKEND:		equ	$5C65    ; Address of start of spare space
BREG:		equ	$5C67    ; Calculator's B register
MEM:		equ	$5C68    ; Address of area used for calculator's memory
FLAGS2:		equ	$5C6A    ; More flags
DF_SZ:		equ	$5C6B    ; The number of lines in the lower part of the screen
S_TOP:		equ	$5C6C    ; The number of the top program line in automatic listings
OLDPPC:		equ	$5C6E    ; Line number to which CONTINUE jumps
OSPCC:		equ	$5C70    ; Number within line of statement to which CONTINUE jumps
FLAGX:		equ	$5C71    ; Various flags
STRLEN:		equ	$5C72    ; Length of string type destination in assignment
T_ADDR:		equ	$5C74    ; Address of next item in parameter table
SEED:		equ	$5C76    ; The seed for RND
FRAMES:		equ	$5C78    ; Frame counter
UDG:		equ	$5C7B    ; Address of first user defined graphic
COORDS:		equ	$5C7D    ; Coordinates of last point plotted
P_POSN:		equ	$5C7F    ; Column number of printer position
PR_CC:		equ	$5C80    ; Address of next position for LPRINT to print at
ECHO_E:		equ	$5C82    ; Column and line number of end of input buffer
DF_CC:		equ	$5C84    ; Address in display file of PRINT position
DF_CCL:		equ	$5C86    ; Like DF_CC for lower part of screen
S_POSN:		equ	$5C88    ; Column and line number for PRINT position
S_POSNL:	equ	$5C8A    ; Like S_POSN for lower part of screen
SCR_CT:		equ	$5C8C    ; Scroll counter
ATTR_P:		equ	$5C8D    ; Permanent current colours
MASK_P:		equ	$5C8E    ; Used for transparent colours
ATTR_T:		equ	$5C8F    ; Temporary current colours
MASK_T:		equ	$5C90    ; Temporary transparent colours
P_FLAG:		equ	$5C91    ; More flags
MEMBOT:		equ	$5C92    ; Calculator's memory area
NMIADD:		equ	$5CB0    ; Non_maskable interrupt address
RAMTOP:		equ	$5CB2    ; Address of last byte of BASIC system area
P_RAMT:		equ	$5CB4    ; Address of last byte of physical RAM

;*************************************************************************************
;Ports
;*************************************************************************************
;48K
PORT_ULA:           equ $FE
;128K
PORT_AY_REGISTER:   equ $FFFD
PORT_AY_DATA:       equ $BFFD
PORT_MEM1:          equ $7FFD
PORT_IF2_1:         equ $EFFE
PORT_IF2_2:         equ $F7FE
;+2A / +3
PORT_MEM2:          equ $1FFD
PORT_FDC_STATUS:    equ $2FFD
PORT_FDC_DATA:      equ $3FFD
PORT_CENTRONICSDAT: equ $0FFD






