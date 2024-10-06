#!/bin/bash

set -eu

PROMPT=$1
TARGET_NAME=$2

. ./.env

function createImage() {
     local PAYLOAD
     PAYLOAD='{"prompt":"'"$PROMPT"'","process_mode":"fast"}'

     CREATE_RESP=$(curl -s -X POST \
          -H "Content-Type: application/json"  \
          -H "X-API-KEY: $API_KEY"  \
          -d "$PAYLOAD"  \
          'https://api.piapi.ai/mj/v2/imagine')

     echo "$CREATE_RESP" >> run.log

     TASK_ID=$(echo $CREATE_RESP | jq -r '.task_id')
}

createImage

STATUS_RESP='{"status":""}'
COUNTER=0
while [ "$(echo $STATUS_RESP | jq -r '.status')" != "finished" ]; do
     sleep 10
     STATUS_RESP=$(curl -s -X POST  \
          -H "Content-Type: application/json"  \
          -d '{"task_id":"'"$TASK_ID"'"}'  \
          'https://api.piapi.ai/mj/v2/fetch')

     echo "$STATUS_RESP" >> run.log
     COUNTER=$(( COUNTER + 1 ))

     if [ "$(echo $STATUS_RESP | jq -r '.status')" = "failed" ]; then
          createImage
          COUNTER=0
     fi

     if [ "$COUNTER" -gt 20 ]; then
          echo "Exceeded 20 tries"
          createImage
          COUNTER=0
     fi
done;

TASK_RESULT_IMAGE_URL=$(echo -n "$STATUS_RESP" | jq -r '.task_result.discord_image_url')

mkdir -p $TARGET_NAME

curl -s $TASK_RESULT_IMAGE_URL -o ${TARGET_NAME}/raw.png

OUTPUT_PATH=./

input_image="${TARGET_NAME}/raw.png"

width=$(identify -format "%w" "$input_image")
height=$(identify -format "%h" "$input_image")

half_width=$((width / 2))
half_height=$((height / 2))

magick convert "$input_image" -crop "${half_width}x${half_height}+0+0" "${TARGET_NAME}/1.png"
magick convert "$input_image" -crop "${half_width}x${half_height}+$half_width+0" "${TARGET_NAME}/2.png"
magick convert "$input_image" -crop "${half_width}x${half_height}+0+$half_height" "${TARGET_NAME}/3.png"
magick convert "$input_image" -crop "${half_width}x${half_height}+$half_width+$half_height" "${TARGET_NAME}/4.png"

rm -f ${TARGET_NAME}/raw.png

