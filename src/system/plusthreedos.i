;*****************************************************************
; ZX Spectrom ROM calls (+2A/+2B/+3 ROM 3 (PLUS3DOS) (Jump block) 
; This is copied almost straight from: 
; https://worldofspectrum.org/ZXSpectrum128+3Manual/chapter8pt27.html
;*****************************************************************
;Essential filing system routines
DOS_INITIALISE:		equ $0100   ;Initialise +3DOS
DOS_VERSION:		equ $0103   ;Get +3DOSissue and version numbers
DOS_OPEN:		    equ $0106   ;Create and/or open a file
DOS_CLOSE:		    equ $0109   ;Close a file
DOS_ABANDON:		equ $010C   ;Abandon a file
DOS_REF_HEAD:		equ $010F   ;Point at the header data for this file
DOS_READ:		    equ $0112   ;Read bytes into memory
DOS_WRITE:		    equ $0115   ;Write bytes from memory
DOS_BYTE_READ:		equ $0118   ;Read a byte
DOS_BYTE_WRITE:		equ $011B   ;Write a byte
DOS_CATALOG:		equ $011E   ;Catalog disk directory
DOS_FREE_SPACE:		equ $0121   ;Free space on disk
DOS_DELETE:		    equ $0124   ;Delete a file
DOS_RENAME:		    equ $0127   ;Rename a file
DOS_BOOT:		    equ $012A   ;Boot an operating system or other program
DOS_SET_DRIVE:		equ $012D   ;Set/get default drive
DOS_SET_USER:		equ $0130   ;Set/get default user number

;Additional routines for games and operating systems
DOS_GET_POSITION:	equ $0133   ;Get file pointer for random access
DOS_SET_POSITION:	equ $0136   ;Set file pointer for random access
DOS_GET_EOF:	    equ $0139   ;Get end of file position for random access
DOS_GET_1346:		equ $013C   ;Get memory usage in pages 1, 3, 4, 6
DOS_SET_1346:		equ $013F   ;Re-allocate memory usage in pages 1, 3, 4, 6
DOS_FLUSH:		    equ $0142   ;Bring disk up to date
DOS_SET_ACCESS:		equ $0145   ;Change open file's access mode
DOS_SET_ATTRIBUTES:	equ $0148   ;Change a file's attributes
DOS_OPEN_DRIVE:		equ $014B   ;Open a drive as a single file
DOS_SET_MESSAGE:	equ $014E   ;Enable/disable error messages
DOS_REF_XDPB:		equ $0151   ;Point at XDPB for low level disk access
DOS_MAP_B:		    equ $0154   ;Map B: onto unit 0 or 1

;Low level floppy disk driving routines
DD_INTERFACE:		equ $0157   ;Is the floppy disk driver interface present?
DD_INIT:		    equ $015A   ;Initialise disk driver
DD_SETUP:		    equ $015D   ;Specify drive parameters
DD_SET_RETRY:		equ $0160   ;Set try/retry count
DD_READ_SECTOR:		equ $0163   ;Read a sector
DD_WRITE_SECTOR:	equ $0166   ;Write a sector
DD_CHECK_SECTOR:	equ $0169   ;Check a sector
DD_FORMAT:		    equ $016C   ;Format a track
DD_READ_ID:		    equ $016F   ;Read a sector identifier
DD_TEST_UNSUITABLE:	equ $0172   ;Test media suitability
DD_LOGIN:		    equ $0175   ;Log in disk, initialise XDPB
DD_SEL_FORMAT:		equ $0178   ;Pre-initialise XDPB for DD_FORMAT
DD_ASK_1:		    equ $017B   ;Is unit 1 (external drive) present?
DD_DRIVE_STATUS:	equ $017E   ;Fetch drive status
DD_EQUIPMENT:		equ $0181   ;What type of drive?
DD_ENCODE:		    equ $0184   ;Set intercept routine for copy protection
DD_L_XDPB:		    equ $0187   ;Initialise an XDPB from a disk specification
DD_L_DPB:		    equ $018A   ;Initialise a DPB from a disk specification
DD_L_SEEK:		    equ $018D   ;uPD765A seek driver
DD_L_READ:		    equ $0190   ;uPD765A read driver
DD_L_WRITE:		    equ $0193   ;uPD765A write driver
DD_L_ON_MOTOR:		equ $0196   ;Motor on, wait for motor-on time
DD_L_T_OFF_MOTOR:	equ $0199   ;Start the motor-off ticker
DD_L_OFF_MOTOR:		equ $019C   ;Turn the motor off

