# SpecPlus3DiskLoader
Disk catalog and boot loader for Spectrum +3/+3E disks.

Note, there are much better options than this for +3 program selectors.
Use Octocom's Workbench instead for what i consider to be the best.

The only reason this is here is because i started on this before I came across the above, i dont like to leave things unfinished and there are some useful code snippets I would probably lose after my computers next brain fart if i didnt. 

# Features
The program features the following:

o Creates a list of all the *.BAS files:

o Can display information about these files if they exist in the inf file. (See later)

o will load the given file when enter is pressed.

o uses arrow keys to go up and down the list

o caps-shift + arrow for up and down by page

o can use keys to go straight to entries (Eg, X will go straight to X in the list)

...

o and thats it really. Told you it was simple.

# Usage
o Download the latest release disk

o copy the file "disk.bin" and "disk" to the hard drive. (Ignore the rest of the rubbish, its only used while building)

o create a disk.inf file if you can be bothered. (See below)

o run it by using load "disk" or set the drive to be your default partiton using move "part" in "c:" asn : load "c:" asn and just use the disk loader

# Limitations
o its as ugly as heck

o you have to define any text in disk.inf

o only works on one partition

# Disk.inf file
This file contains a list of information to populate the Right hand screen. It can be blank or non-existant. It can have a maximum (useful) filesize of 29184 bytes.

the format is as follows

XXXXXXX NNNNN\*PUB\*YEAR\*NOTES]

where XXXXXXX is the filename padded to 8 bytes with space. 

NNNNN - full name. 

PUB   - Publisher name

YEAR  - publisher year

NOTES - Any text you want to put in there.

Eg, 

ANTATTAK Ant attack\*Quicksilva\*1983\*Classic ant attack game.]

ANTIRAD  Sacred armour of Antirad\*Palace software\*1986\*]

Line wrapping is supported as are CRs

The file should terminate in $$$$$$$$


See the example in the archive.








