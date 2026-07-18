#!/bin/zsh

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
campaign_dir="$repo_root/marketing/creative/campaigns/launch-001"
media_root="$repo_root/marketing/media"
veo_source="$media_root/launch-001/veo-source/med_20260718_dia001__cmp_20260716_launch__veo-source__omni-flash__20260718-1433.mp4"
share_source="$media_root/appstore-private-kundli-2026-07-16/02-appstore.png"
saved_source="$media_root/appstore-private-kundli-2026-07-16/01-appstore.png"
hook_svg="$campaign_dir/edit-assets/dia001-hook.svg"
privacy_svg="$campaign_dir/edit-assets/dia001-privacy-mask.svg"
output_dir="$media_root/launch-001/prototypes/dia001"
output="$output_dir/med_20260718_dia001v3__cmp_20260716_launch__veo-swift-proof-cut__sita-sharma.mp4"

for required_file in "$veo_source" "$share_source" "$saved_source" "$hook_svg" "$privacy_svg"; do
  if [[ ! -f "$required_file" ]]; then
    print -u2 "Missing required source: $required_file"
    exit 1
  fi
done

render_tmp="$(mktemp -d "${TMPDIR:-/tmp}/jyotish-dia001.XXXXXX")"
trap 'rm -rf -- "$render_tmp"' EXIT
mkdir -p "$output_dir"

sips -s format png "$hook_svg" --out "$render_tmp/hook.png" >/dev/null
sips -s format png "$privacy_svg" --out "$render_tmp/privacy-mask.png" >/dev/null

ffmpeg -y -loglevel error \
  -i "$share_source" \
  -i "$render_tmp/privacy-mask.png" \
  -filter_complex \
  "[0:v]scale=1080:2346:flags=lanczos,crop=1080:1920:0:213[base];[base][1:v]overlay=0:0:format=auto" \
  -frames:v 1 \
  "$render_tmp/proof-share.png"

ffmpeg -y -loglevel error \
  -i "$saved_source" \
  -vf "scale=1080:2346:flags=lanczos,crop=1080:1920:0:213" \
  -frames:v 1 \
  "$render_tmp/proof-saved.png"

ffmpeg -y -loglevel warning \
  -i "$veo_source" \
  -loop 1 -framerate 24 -i "$render_tmp/proof-share.png" \
  -loop 1 -framerate 24 -i "$render_tmp/proof-saved.png" \
  -loop 1 -framerate 24 -i "$render_tmp/hook.png" \
  -filter_complex \
  "[0:v]trim=start_frame=0:end_frame=55,setpts=PTS-STARTPTS,scale=1080:1920:flags=lanczos,fps=24[v0b];\
[3:v]trim=start_frame=0:end_frame=55,setpts=PTS-STARTPTS,format=rgba[hook];\
[v0b][hook]overlay=0:0:format=auto:shortest=1[v0];\
[1:v]trim=start_frame=0:end_frame=58,setpts=PTS-STARTPTS,scale=1080:1920:flags=lanczos,fps=24[v1];\
[0:v]trim=start_frame=144:end_frame=161,setpts=PTS-STARTPTS,scale=1080:1920:flags=lanczos,fps=24[v2];\
[2:v]trim=start_frame=0:end_frame=62,setpts=PTS-STARTPTS,scale=1080:1920:flags=lanczos,fps=24[v3];\
[v0][v1][v2][v3]concat=n=4:v=1:a=0[outv];\
[0:a]atrim=start=0:end=8,asetpts=PTS-STARTPTS[outa]" \
  -map "[outv]" \
  -map "[outa]" \
  -r 24 \
  -c:v libx264 \
  -preset medium \
  -crf 20 \
  -pix_fmt yuv420p \
  -c:a aac \
  -b:a 192k \
  -movflags +faststart \
  "$output"

ffprobe -v error \
  -show_entries format=duration,size:stream=index,codec_type,width,height,r_frame_rate,nb_frames \
  -of default=noprint_wrappers=1 \
  "$output"

print "$output"
