#!/bin/bash

BASE=/home/XXXX/work/dev/z80
PROJECTBASE=$BASE/Projects/DiskLoader
SRC=$PROJECTBASE/src
OUT=$PROJECTBASE/out
LBL=$PROJECTBASE/labels
LIST=$PROJECTBASE/listing
cd $PROJECTBASE
rm $OUT/*
rm $LBL/*
rm $LIST/*
clear

function compile( ) {
   echo Compiling $2
   z80asm --verbose -v --input $SRC/$2 --output $OUT/$1.bin --list=$LIST/$1.list --label=$LBL/$1.lbl
}
# build the code
cd $PROJECTBASE/src

compile "diskload"      "diskload.asm"
compile "diskcat" "diskcat.asm"
compile "keyboard" "keyboard.asm"
compile "loaddiskinf" "loaddiskinf.asm"
compile "loadprog" "loadprog.asm"

#build the disk image
cd $BASE
java -jar $BASE/bin/HDDFileEditor.jar script=$PROJECTBASE/diskbuild.script

#Start fuse
HD="--simpleide --simpleide-masterfile=$BASE/dsk/newdisk.hdf"
FDD="--plus3disk $PROJECTBASE/dev.dsk"
JS="--kempston --joystick-1 /dev/input/js1 --joystick-1-output 2"
#NOL=" --no-auto-load"
#MOUSE="--kempston-mouse"

fuse --machine plus3e $MOUSE $NOL $FDD $HD $JS
