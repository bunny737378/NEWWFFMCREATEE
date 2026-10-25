#!/usr/bin/env bash

# Script to package compiled FFmpeg libraries into an MX Player custom codec All-In-One (AIO) ZIP
# Compatible with MX Player's "Custom Codec" loader.

BASE_DIR=${BASE_DIR:-"$( cd "$( dirname "$0" )/.." && pwd )"}
OUTPUT_DIR=${OUTPUT_DIR:-"${BASE_DIR}/output"}
BUILD_DIR_FFMPEG=${BUILD_DIR_FFMPEG:-"${BASE_DIR}/build/ffmpeg"}

AIO_DIR="${OUTPUT_DIR}/aio"
rm -rf "${AIO_DIR}"
mkdir -p "${AIO_DIR}"

echo "============================================="
echo "Packaging MX Player Custom Codec (AIO ZIP)..."
echo "============================================="

FOUND_ANY_SO=false

for ABI in "arm64-v8a" "armeabi-v7a" "x86" "x86_64"
do
  SO_FILE=""
  # Check priority locations for libffmpeg.mx.so or libffmpeg.so
  if [ -f "${OUTPUT_DIR}/mxplayer/${ABI}/libffmpeg.mx.so" ]; then
    SO_FILE="${OUTPUT_DIR}/mxplayer/${ABI}/libffmpeg.mx.so"
  elif [ -f "${OUTPUT_DIR}/lib/${ABI}/libffmpeg.mx.so" ]; then
    SO_FILE="${OUTPUT_DIR}/lib/${ABI}/libffmpeg.mx.so"
  elif [ -f "${BUILD_DIR_FFMPEG}/${ABI}/lib/libffmpeg.mx.so" ]; then
    SO_FILE="${BUILD_DIR_FFMPEG}/${ABI}/lib/libffmpeg.mx.so"
  elif [ -f "${OUTPUT_DIR}/mxplayer/${ABI}/libffmpeg.so" ]; then
    SO_FILE="${OUTPUT_DIR}/mxplayer/${ABI}/libffmpeg.so"
  elif [ -f "${OUTPUT_DIR}/lib/${ABI}/libffmpeg.so" ]; then
    SO_FILE="${OUTPUT_DIR}/lib/${ABI}/libffmpeg.so"
  elif [ -f "${BUILD_DIR_FFMPEG}/${ABI}/lib/libffmpeg.so" ]; then
    SO_FILE="${BUILD_DIR_FFMPEG}/${ABI}/lib/libffmpeg.so"
  fi

  if [ -n "${SO_FILE}" ] && [ -f "${SO_FILE}" ]; then
    FOUND_ANY_SO=true
    echo "Found codec binary for ${ABI}: ${SO_FILE}"
    mkdir -p "${AIO_DIR}/${ABI}"
    cp "${SO_FILE}" "${AIO_DIR}/${ABI}/libffmpeg.mx.so"
    cp "${SO_FILE}" "${AIO_DIR}/${ABI}/libffmpeg.so"

    # If armeabi-v7a, also create neon directory (standard for MX Player ARMv7 NEON)
    if [ "${ABI}" = "armeabi-v7a" ]; then
      mkdir -p "${AIO_DIR}/neon"
      cp "${SO_FILE}" "${AIO_DIR}/neon/libffmpeg.mx.so"
      cp "${SO_FILE}" "${AIO_DIR}/neon/libffmpeg.so"
    fi

    # Also build individual standalone ZIP for this ABI
    STANDALONE_ZIP_DIR="${OUTPUT_DIR}/standalone_${ABI}"
    rm -rf "${STANDALONE_ZIP_DIR}"
    mkdir -p "${STANDALONE_ZIP_DIR}"
    cp "${SO_FILE}" "${STANDALONE_ZIP_DIR}/libffmpeg.mx.so"
    cp "${SO_FILE}" "${STANDALONE_ZIP_DIR}/libffmpeg.so"
    (cd "${STANDALONE_ZIP_DIR}" && zip -q "${OUTPUT_DIR}/mx_${ABI}.zip" libffmpeg.mx.so libffmpeg.so)
    rm -rf "${STANDALONE_ZIP_DIR}"
    echo "Created standalone package: ${OUTPUT_DIR}/mx_${ABI}.zip"
  fi
done

if [ "$FOUND_ANY_SO" = false ]; then
  echo "No libffmpeg.mx.so or libffmpeg.so found. Please build FFmpeg with --profile=mxplayer or --build-mx-so first."
  exit 0
fi

# Create README with usage instructions for MX Player
cat > "${AIO_DIR}/README.txt" << 'EOF'
========================================================================
             MX Player Custom Codec - All-In-One (AIO)
========================================================================

This package contains full FFmpeg custom codec libraries for MX Player
with support for all proprietary and advanced audio, video, and subtitle
formats.

[SUPPORTED DECODERS]
- Audio:
  * Dolby Digital (AC-3, AC-3 Fixed)
  * Dolby Digital Plus / Atmos Core (E-AC-3)
  * Dolby TrueHD
  * Meridian Lossless Packing (MLP)
  * DTS, DTS-HD Master Audio, DTS:X Core (DCA)
  * AAC (AAC-LC, HE-AAC v1/v2, AAC-LD)
  * Opus, MP3, Vorbis, FLAC, Apple Lossless (ALAC)
  * Monkey's Audio (APE), WavPack (WV)
  * Windows Media Audio (WMAv1, WMAv2, WMA Pro, WMA Lossless)
  * RealAudio (Cook, 14.4, 28.8, ATRAC3)
  * AMR-NB, AMR-WB, DSD (SACD)

- Video:
  * HEVC / H.265 (8-bit, 10-bit HDR, Main10)
  * H.264 / AVC (High 10, Hi10P, Baseline, Main, High)
  * AV1 (via libdav1d ultra-fast decoder)
  * VP9, VP8 (via libvpx)
  * MPEG-4 (DivX, XviD), MS-MPEG4
  * MPEG-1, MPEG-2 (DVD, DVB)
  * VC-1, WMV1, WMV2, WMV3
  * Apple ProRes (422, 4444, HQ, Proxy)
  * RealVideo (RV10, RV20, RV30, RV40)
  * Motion JPEG, Sorenson Spark, Theora

- Hardware Acceleration:
  * Android MediaCodec (H264, HEVC, MPEG4, VP8, VP9, AV1)
  * JNI HW surface bindings

- Subtitles:
  * Advanced SubStation Alpha / SSA with libass (Full styled fonts & karaoke)
  * SubRip (.srt), WebVTT (.vtt)
  * HDMV PGS (Blu-ray subtitles)
  * DVD VobSub (.sub/.idx)
  * DVB Subtitles & DVB Teletext
  * QuickTime / MP4 text (.mov_text)
  * SAMI, MicroDVD, JacoSub, RealText, EIA-608 Closed Captions

[HOW TO INSTALL IN MX PLAYER]
1. Copy 'mx_aio.zip' to your Android device (e.g. into the Download folder).
2. Open MX Player on your phone or Android TV.
3. Tap the Settings icon (or Menu -> Settings).
4. Go to 'Decoder' settings.
5. Scroll all the way down to 'Custom codec'.
6. Tap 'Custom codec' and browse to select 'mx_aio.zip'.
7. MX Player will prompt: "Restart app to use custom codec?". Tap OK.
8. MX Player will restart and display: "Using custom codec: libffmpeg.mx.so".
9. Open any video with EAC3, TrueHD, DTS, or 10-bit HEVC and enjoy flawless playback!
========================================================================
EOF

# Create JSON metadata manifest
cat > "${AIO_DIR}/codec_manifest.json" << 'EOF'
{
  "name": "MX Player Custom Codec Ultimate",
  "version": "8.1.2",
  "type": "aio",
  "libraries": ["libffmpeg.mx.so", "libffmpeg.so"],
  "architectures": ["arm64-v8a", "armeabi-v7a", "neon", "x86", "x86_64"],
  "audio_decoders": [
    "ac3", "ac3_fixed", "eac3", "truehd", "mlp", "dca", "aac", "opus",
    "mp3", "vorbis", "flac", "alac", "ape", "wavpack", "wma", "wmav1",
    "wmav2", "wmapro", "wmalossless", "amrnb", "amrwb", "cook", "dsd"
  ],
  "video_decoders": [
    "hevc", "h264", "av1", "vp9", "vp8", "mpeg4", "mpeg1video", "mpeg2video",
    "vc1", "wmv1", "wmv2", "wmv3", "rv10", "rv20", "rv30", "rv40", "prores"
  ],
  "hardware_acceleration": [
    "h264_mediacodec", "hevc_mediacodec", "mpeg4_mediacodec",
    "vp8_mediacodec", "vp9_mediacodec", "av1_mediacodec"
  ],
  "subtitle_decoders": [
    "libass", "ass", "ssa", "subrip", "webvtt", "pgssub", "dvdsub",
    "dvbsub", "teletext", "mov_text", "microdvd", "sami", "cc_dec"
  ]
}
EOF

# Create the All-In-One ZIP archive
AIO_ZIP="${OUTPUT_DIR}/mx_aio.zip"
rm -f "${AIO_ZIP}"
(cd "${AIO_DIR}" && zip -rq "${AIO_ZIP}" .)

echo "Successfully generated MX Player All-In-One Custom Codec package:"
echo " -> ${AIO_ZIP}"
ls -lh "${AIO_ZIP}"
