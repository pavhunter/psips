#!/bin/bash

base="/var/www/html"

set -x

rm -rf live live.h264 "$base/live"
mkdir -p live
ln -s "$PWD/live" "$base/live"

# fifos seem to work more reliably than pipes - and the fact that the
# fifo can be named helps ffmpeg guess the format correctly.
mkfifo live.h264
raspivid -w 1920 -h 1080 -fps 30 -t 86400000 -b 25000000 -o - | psips > live.h264 &
#raspivid -w 1920 -h 1080 -fps 25 -t 86400000 -b 15000000 -o - | psips > live.h264 &

# Letting the buffer fill a little seems to help ffmpeg to id the stream
sleep 2

# Need ffmpeg around 1.0.5 or later. The stock Debian ffmpeg won't work.
# I'm not aware of options apart from building it from source. I have
# Raspbian packags built from Debian Multimedia sources. Available on
# request but I don't want to post them publicly because I haven't cross
# compiled all of Debian Multimedia and conflicts can occur.
#  -c:a aac -b:a 128k \
#  -hls_wrap 11 \
#-hls_playlist_type vod \
ffmpeg -y \
  -i live.h264 \
  -f s16le -i /dev/zero -r:a 48000 -ac 2 \
  -c:v copy \
  -map 0:0 -map 1:0 \
  -f hls \
  -hls_time 8 \
  -hls_list_size 9 \
  -hls_wrap 10 \
  -hls_flags delete_segments \
  -hls_segment_filename "live/%08d.ts" \
  "$base/live/live.m3u8"

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


#  -f hls \
#  -hls_time 8 \
#  -hls_list_size 10 \
#  -hls_playlist_type vod \
#  -hls_flags delete_segments \
#  -hls_segment_filename "live/%08d.ts" \
#  "$base/live/live.m3u8"

#  -hls_segment_type mpegts \
#  -segment_list_flags live \
#  -segment_list_type m3u8 \
#  "live/%08d.ts" < /dev/null

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

# vim:ts=2:sw=2:sts=2:et:ft=sh