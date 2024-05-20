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
#
# Directory process etc
#845  20/05/24 21:39:20 find  ~/Music/zzz/ -type f -name *.ogg > list-ogg.txt
#846  20/05/24 21:39:28 cat list-ogg.txt
#847  20/05/24 21:39:40 find  ~/Music/zzz/ -type f -name *.flac > list-flac.txt
#848  20/05/24 21:39:47 cat list-flac.txt
#849  20/05/24 21:39:58 rm list.txt
#850  20/05/24 21:40:16 find  ~/Music/zzz/a_positive_life -type f -name *.ogg > list.txt
#851  20/05/24 21:42:36 FILES="cat list.txt"
#852  20/05/24 21:42:41 echo $FILES
#853  20/05/24 21:42:49 FILES=`cat list.txt`
#854  20/05/24 21:42:50 echo $FILES
#855  20/05/24 21:43:13 for i in $FILES;do echo $i; done;
#856  20/05/24 21:43:28 for i in $FILES;do echo file is $i; done;
#857  20/05/24 21:43:44 for i in $FILES;do echo rpocessing  $i; done;
#858  20/05/24 21:44:07 for i in $FILES;do echo rpocessing  $i; ./ffprobe.exe $i -export_all true; done;
#859  20/05/24 21:45:54 for i in $FILES;do echo rpocessing  $i;  ./ffmpeg.exe  -stats -i "$i"  -map_metadata 0:s:0 -acodec alac "${i%.*}.m4a"; done;

