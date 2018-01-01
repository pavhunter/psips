#!/bin/bash

#ffmpeg -y \
#  -i live.h264 \
#  -f s16le -i /dev/zero -r:a 48000 -ac 2 \
#  -c:v copy \
#  -map 0:0 -map 1:0 \
#  -f segment \
#  -hls_flags delete_segments \
#  -segment_time 8 \
#  -segment_format mpegts \
#  -segment_list "$base/live/live.m3u8" \
#  -segment_list_size 10 \
#  -segment_list_flags live \
#  -segment_list_type m3u8 \
#  "live/%08d.ts" < /dev/null

INPUT="http://192.168.1.5/live/live.m3u8"
VBR="1M"                                    # Bitrate de la vidéo en sortie
FPS="25"                                       # FPS de la vidéo en sortie
QUAL="medium"                                  # Preset de qualité FFMPEG
YOUTUBE_URL="rtmp://a.rtmp.youtube.com/live2"  # URL de base RTMP youtube
KEY=""                                     # Clé à récupérer sur l'event youtube

ffmpeg \
    -re -i $INPUT \
    -c:v copy \
    -c:a aac -ar 44100 -ab 128k -ac 2 -strict -2 -flags +global_header -bsf:a aac_adtstoasc \
    -f flv "$YOUTUBE_URL/$KEY"
