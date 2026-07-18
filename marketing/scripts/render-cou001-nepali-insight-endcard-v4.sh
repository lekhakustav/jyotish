#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source_video="$repo_root/marketing/media/launch-001/veo-source/med_20260718_cou001__cmp_20260716_launch__veo-source__omni-flash__20260718-1836.mp4"
main_voice="$repo_root/marketing/media/launch-001/voice-source/cou001/med_20260718_cou001vo2__cmp_20260716_launch__nepali-couple-insight__karki.mp3"
brand_voice="$repo_root/marketing/media/launch-001/voice-source/cou001/med_20260718_cou001tag1__cmp_20260716_launch__spoken-brand__karki.mp3"
brand_logo="$repo_root/assets/brand/jyotish-baje-logo-imagegen-transparent.png"
end_card="$repo_root/marketing/media/launch-001/prototypes/cou001/med_20260718_cou001v4__store-endcard.png"
output_video="${1:-$repo_root/marketing/media/launch-001/prototypes/cou001/med_20260718_cou001v4__cmp_20260716_launch__spoken-brand__store-endcard.mp4}"

mkdir -p "$(dirname "$output_video")"

"$repo_root/marketing/scripts/render-jyotish-store-endcard.swift" "$end_card" "$brand_logo" >/dev/null

ffmpeg -hide_banner -loglevel error -y \
  -i "$source_video" \
  -i "$main_voice" \
  -i "$brand_voice" \
  -loop 1 -i "$end_card" \
  -filter_complex "
    [0:v]trim=duration=8,setpts=PTS-STARTPTS,scale=720:1280,setsar=1[scene];
    [3:v]trim=duration=2.5,setpts=PTS-STARTPTS,
      scale=720:1280,setsar=1,fade=t=in:st=0:d=0.25[card];
    [scene][card]concat=n=2:v=1:a=0,fps=24,format=yuv420p[vout];
    [0:a]atrim=duration=8,asetpts=PTS-STARTPTS,
      volume='if(between(t,0.35,7.35),0.10,0.28)',
      afade=t=out:st=7.65:d=0.35,
      apad=pad_dur=2.5[ambience];
    [1:a]atrim=end=5.55,afade=t=out:st=5.35:d=0.20,
      adelay=350|350,volume=1.28,apad=pad_dur=4.6[voice];
    [2:a]atrim=start=0.05:end=1.05,asetpts=PTS-STARTPTS,
      afade=t=in:st=0:d=0.05,afade=t=out:st=0.88:d=0.12,
      adelay=6000|6000,volume=1.28,apad=pad_dur=3.5[brand];
    [ambience][voice][brand]amix=inputs=3:duration=longest:normalize=0,
      alimiter=limit=0.95,
      atrim=duration=10.5,asetpts=PTS-STARTPTS[aout]
  " \
  -map "[vout]" \
  -map "[aout]" \
  -c:v libx264 \
  -preset medium \
  -crf 18 \
  -c:a aac \
  -b:a 192k \
  -movflags +faststart \
  -t 10.5 \
  "$output_video"

printf '%s\n' "$output_video"
