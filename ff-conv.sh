#!/bin/sh
#
# some ffmpeg conversion stuff i did on Windows in the git bash tol.
#
#
#
# this works - it will copy the metadata over as you'd hope it would
# see commens further below
for i in  ~/Music/zzz/a_positive_life/synaesthetic/*.ogg; do ./ffmpeg.exe  -stats -i "$i"  -map_metadata 0:s:0 -acodec alac "${i%.*}.m4a"; done

# probe it:
./ffprobe.exe  ~/Music/zzz/a_positive_life/synaesthetic/aquasonic.m4a -export_all true

# 
# Comments
# For example to copy metadata from the first stream of the input file to global metadata of the output file:

ffmpeg -i in.ogg -map_metadata 0:s:0 out.mp3

# from here:
# https://ffmpeg.org//ffmpeg.html#Video-and-Audio-file-format-conversion
