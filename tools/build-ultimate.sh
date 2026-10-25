#!/usr/bin/env bash

# Convenience script to compile FFmpeg with full ultimate profile for ANY Android app
# Usage: ./tools/build-ultimate.sh [-abis=arm64-v8a,armeabi-v7a,...]

BASE_DIR="$( cd "$( dirname "$0" )/.." && pwd )"

echo "=========================================================="
echo " Starting FFmpeg Compilation (Ultimate Universal Profile)"
echo "=========================================================="

"${BASE_DIR}/ffmpeg-android-maker.sh" --profile=ultimate "$@"
