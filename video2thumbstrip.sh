#!/usr/bin/env bash

# usage:
# ./video2thumbstrip.sh input_video.mp4 output_strip.jpg

# input video
VIDEO=$1

# output thumbnail-strip
OUTPUT=$2

# fps
FPS=${3:-15}

# create tmp thumbnails
ffmpeg -loglevel panic -i $VIDEO -vf fps=1/$FPS tmp_thumb%03d.jpg

# detect black images and remove
for f in tmp_thumb*.jpg; do
    mean=`convert $f -format "%[mean]" info:`
    threshold=6500
    if [ $(echo "$mean < $threshold" | bc) -ne 0 ]; then
        rm ./$f
        #echo "deleted $f with mean $mean"
    fi
done

# get number of tmp thumbnails generated
THUMBCOUNT=$(ls tmp_thumb*.jpg | wc -l)

# create thumbnail strip
ffmpeg -loglevel panic -pattern_type glob -i "tmp_thumb*.jpg" -filter_complex tile=1x$THUMBCOUNT $OUTPUT

# remove tmp thumbnails
rm ./tmp_thumb*.jpg

# resize image to width
convert $OUTPUT -resize 600 -quality 50% $OUTPUT

# optimize output image
jpegoptim $OUTPUT