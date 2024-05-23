20 load "diskload.bin" code 
30 load "diskcat.bin" code
40 load "keyboard.bin" code
50 load "loadprog.bin" code
60 load "loadinfo.bin" code
70 move "c:" out
80 move "c:" in "int-sn2"
90 copy "disk.inf" to "c:"
100 save "a:disk.bin" code 26368,2560
110 load "c:"
120 Randomise usr 26368

