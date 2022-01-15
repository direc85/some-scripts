#!/bin/bash
###
# convert_screenshots.sh
# (c) direc85 2022
# License: GPLv2
#
#   CAUTION: Experimental script! Use at your own risk!
#
# Converts the PNG screenshots to JPG format
# and deletes the original files (yesterday and older).
#
# Requires ImageMagick (available in e.g. Sailfish Chum)
###

# This should be always the same. Change if needed.
SCREENSHOTS=$HOME/Pictures/Screenshots

# Better the quality, bigger the JPG file.
# Recommendation: 90...95
QUALITY=95

# Run (at most) one `convert` process per core.
# Sailfish OS doesn't have `nproc` so let's improvise...
TASKS=$(cat /proc/cpuinfo | grep "processor.:" | wc -l)

### Check that ImageMagick is installed
if [ $(which convert | wc -l) -ne 1 ]
then
  echo "Error: 'convert' not found."
  echo "Please install ImageMagick first."
  exit 1
fi

### Check the screenshots dir
if [ ! -d $SCREENSHOTS ]
then
  echo "Folder \"$SCREENSHOTS\" doesn't exist."
  exit 2
fi
cd $SCREENSHOTS

### List the screenshot PNG files and count them
LIST=/tmp/png_screenshots.txt
ls *.png | egrep "_[0-9]{8}_[0-9]{3}.png$" > $LIST
COUNT=$(cat $LIST | wc -l)
if [ $COUNT -lt 1 ]
then
  echo No screenshots found.
  exit 3
fi

### Part of a screenshot filename that was taken today
TODAY=_$(date +%Y%m%d)_

PROGRESS=0
for PNG in $(cat $LIST)
do
  let PROGRESS=PROGRESS+1

  ### Rename PNG to JPG and make it start with
  ### "Screenshot" instead of a localized filename.
  JPG=$(echo $PNG | sed -r 's/^[^_]*(.*)\.png$/Screenshot\1\.jpg/')

  ### Don't process PNG files again
  if [ -f $JPG ]
  then
    echo "[$PROGRESS/$COUNT] $PNG already converted."
    if [ $(ls $PNG | grep $TODAY | wc -l) -eq 0 ]
    then
      rm $PNG
    fi
    continue
  fi

  ### To speed things up, run `convert` in parallel
  (
    CURR_PNG=$PNG
    CURR_JPG=$JPG
    echo "[$PROGRESS/$COUNT] $CURR_PNG > $CURR_JPG"
    convert $CURR_PNG -quality $QUALITY /tmp/$CURR_JPG

    ### Only remove PNG if the conversion was successful

    if [ $? -eq 0 ]
    then
      ### Preserve the timestamp to have some
      ### sort of hope of having images in order...

      touch -r $CURR_PNG /tmp/$CURR_JPG
      mv /tmp/$CURR_JPG ./
      if [ $(ls $PNG | grep $TODAY | wc -l) -eq 0 ]
      then
        rm $PNG
      fi
    else
      rm /tmp/$CURR_JPG >/dev/null
    fi
  ) &

  ### If we are running one per core already,
  ### wait for one `convert` to finish
  if [[ $(jobs -p | wc -l) -ge $TASKS ]]; then
    wait -n
  fi
done
wait
