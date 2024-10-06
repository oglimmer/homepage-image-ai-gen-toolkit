#!/bin/bash

set -eu

for dir in */; do
  dir=${dir%?}
  FILE_NAME=$(ls $dir | head -1)
  ABS_FILE_NAME_PNG="${dir}/${FILE_NAME}"
  ABS_FILE_NAME_NO_EXT="${dir}/${FILE_NAME%.*}"
  convert "$ABS_FILE_NAME_PNG" "${ABS_FILE_NAME_NO_EXT}.jpg"
  convert "${ABS_FILE_NAME_NO_EXT}.jpg" -resize "414x414>" "${ABS_FILE_NAME_NO_EXT}.jpg"
  mv "${ABS_FILE_NAME_NO_EXT}.jpg" ./${dir}.jpg
  rm -rf "$dir"
done