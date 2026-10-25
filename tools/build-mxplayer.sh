#!/usr/bin/env bash

# Convenience script to compile FFmpeg with full MX Player Custom Codec profile
# Usage: ./tools/build-mxplayer.sh [-abis=arm64-v8a,armeabi-v7a,...]

BASE_DIR="$( cd "$( dirname "$0" )/.." && pwd )"

echo "=========================================================="
echo " Starting FFmpeg Compilation (MX Player Ultimate Profile)"
echo "=========================================================="

"${BASE_DIR}/ffmpeg-android-maker.sh" --profile=mxplayer "$@"
