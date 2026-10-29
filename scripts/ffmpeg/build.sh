#!/usr/bin/env bash

case $ANDROID_ABI in
  x86)
    # Disabling assembler optimizations, because they have text relocations
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --disable-asm"
    ;;
  x86_64)
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --x86asmexe=${NASM_EXECUTABLE}"
    ;;
esac

if [ "$FFMPEG_GPL_ENABLED" = true ] ; then
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-gpl --enable-version3"
fi

# Enable Android MediaCodec & JNI hardware acceleration
if [ "$ENABLE_MEDIACODEC" = true ] || [ "$ULTIMATE_PROFILE" = true ] || [ "$MX_PROFILE" = true ]; then
  EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-jni --enable-mediacodec"
  EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-decoder=h264_mediacodec --enable-decoder=hevc_mediacodec --enable-decoder=mpeg4_mediacodec --enable-decoder=vp8_mediacodec --enable-decoder=vp9_mediacodec --enable-decoder=av1_mediacodec"
  EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-hwaccel=h264_mediacodec --enable-hwaccel=hevc_mediacodec --enable-hwaccel=mpeg4_mediacodec --enable-hwaccel=vp8_mediacodec --enable-hwaccel=vp9_mediacodec --enable-hwaccel=av1_mediacodec"
fi

# Ultimate / Universal Comprehensive Decoder Coverage (Same power as MX Player, usable in any app)
if [ "$ULTIMATE_PROFILE" = true ] || [ "$MX_PROFILE" = true ]; then
  # Comprehensive Audio Decoders (AC3, EAC3, TrueHD, MLP, DTS/DCA, AAC, Opus, FLAC, ALAC, APE, WMA, Cook, AMR, etc.)
  ALL_AUDIO_DECODERS="--enable-decoder=ac3,ac3_fixed,eac3,truehd,mlp,dca,aac,aac_latm,aac_fixed,opus,vorbis,flac,alac,ape,wavpack,wma,wmav1,wmav2,wmapro,wmalossless,wma_voice,amrnb,amrwb,cook,ra_144,ra_288,atrac1,atrac3,atrac3plus,dsd_lsbf,dsd_msbf,dsd_lsbf_planar,dsd_msbf_planar,mp3,mp3float,mp3on4,pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,pcm_bluray,pcm_dvd"
  ALL_AUDIO_PARSERS="--enable-parser=ac3,eac3,dca,mlp,aac,flac,opus,vorbis,mpegaudio,cook"
  ALL_AUDIO_DEMUXERS="--enable-demuxer=ac3,eac3,dts,dtshd,truehd,mlp,aac,flac,ogg,wav,ape,wv,amr,rm"

  # Comprehensive Video Decoders (HEVC, H264, AV1, VP9, VP8, MPEG4, VC1, RV40, ProRes, etc.)
  ALL_VIDEO_DECODERS="--enable-decoder=hevc,h264,av1,vp9,vp8,mpeg4,msmpeg4v1,msmpeg4v2,msmpeg4v3,mpeg1video,mpeg2video,vc1,wmv1,wmv2,wmv3,wmv3image,rv10,rv20,rv30,rv40,prores,theora,flv1,vp6,vp6a,vp6f,mjpeg,mjpegb,binkvideo,cinepak"
  ALL_VIDEO_PARSERS="--enable-parser=hevc,h264,av1,vp9,vp8,mpeg4video,mpegvideo,vc1,mjpeg,rv30,rv40"
  ALL_VIDEO_DEMUXERS="--enable-demuxer=matroska,mov,avi,mpegts,mpegps,flv,asf,rm,mjpeg,h264,hevc"

  # Comprehensive Subtitle Decoders (ASS/SSA, SubRip, WebVTT, PGS, VobSub, DVB, Teletext, MOV text, etc.)
  ALL_SUBTITLE_DECODERS="--enable-decoder=ass,ssa,subrip,webvtt,pgssub,dvdsub,dvbsub,teletext,mov_text,microdvd,sami,jacosub,realtext,cc_dec,xsub,mpl2,subviewer,text"
  ALL_SUBTITLE_PARSERS="--enable-parser=dvdsub,dvbsub"
  ALL_SUBTITLE_DEMUXERS="--enable-demuxer=srt,webvtt,ass,microdvd,sami,vobsub,subviewer,realtext"

  # Comprehensive Protocols & Core Filters
  ALL_PROTOCOLS="--enable-protocol=file,pipe,http,https,tls,tcp,udp,rtp,rtsp,rtmp,crypto,hls,concat,data,subfile"
  ALL_FILTERS="--enable-filter=aresample,aformat,volume,scale,crop,format,fps,null"

  EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS $ALL_AUDIO_DECODERS $ALL_AUDIO_PARSERS $ALL_AUDIO_DEMUXERS $ALL_VIDEO_DECODERS $ALL_VIDEO_PARSERS $ALL_VIDEO_DEMUXERS $ALL_SUBTITLE_DECODERS $ALL_SUBTITLE_PARSERS $ALL_SUBTITLE_DEMUXERS $ALL_PROTOCOLS $ALL_FILTERS"
fi

# Preparing flags for enabling requested libraries
ADDITIONAL_COMPONENTS=
for LIBRARY_NAME in ${FFMPEG_EXTERNAL_LIBRARIES[@]}
do
  ADDITIONAL_COMPONENTS+=" --enable-$LIBRARY_NAME"
done

# Referencing dependencies without pkgconfig
DEP_CFLAGS="-I${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/include"
DEP_LD_FLAGS="-L${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib $FFMPEG_EXTRA_LD_FLAGS"

# Android 15 with 16 kb page size support
# https://developer.android.com/guide/practices/page-sizes#compile-r27
EXTRA_LDFLAGS="-Wl,-z,max-page-size=16384 $DEP_LD_FLAGS"

# Determine static/shared options (static needed if building unified single library)
STATIC_SHARED_FLAGS="--enable-shared"
if [ "$BUILD_SINGLE_SO" = true ] || [ "$ULTIMATE_PROFILE" = true ] || [ "$BUILD_MX_SO" = true ] || [ "$MX_PROFILE" = true ]; then
  STATIC_SHARED_FLAGS="--enable-shared --enable-static"
else
  STATIC_SHARED_FLAGS="--enable-shared --disable-static"
fi

./configure \
  --prefix=${BUILD_DIR_FFMPEG}/${ANDROID_ABI} \
  --enable-cross-compile \
  --target-os=android \
  --arch=${TARGET_TRIPLE_MACHINE_ARCH} \
  --sysroot=${SYSROOT_PATH} \
  --cc=${FAM_CC} \
  --cxx=${FAM_CXX} \
  --ld=${FAM_LD} \
  --ar=${FAM_AR} \
  --as=${FAM_CC} \
  --nm=${FAM_NM} \
  --ranlib=${FAM_RANLIB} \
  --strip=${FAM_STRIP} \
  --extra-cflags="-O3 -fPIC $DEP_CFLAGS" \
  --extra-ldflags="$EXTRA_LDFLAGS" \
  ${STATIC_SHARED_FLAGS} \
  --disable-vulkan \
  --pkg-config=${PKG_CONFIG_EXECUTABLE} \
  ${EXTRA_BUILD_CONFIGURATION_FLAGS} \
  $ADDITIONAL_COMPONENTS || exit 1

${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC}
${MAKE_EXECUTABLE} install

# Link unified single libffmpeg.so for simple integration in ANY Android app
if [ "$BUILD_SINGLE_SO" = true ] || [ "$ULTIMATE_PROFILE" = true ] || [ "$BUILD_MX_SO" = true ] || [ "$MX_PROFILE" = true ]; then
  echo "==> Linking unified libffmpeg.so for ${ANDROID_ABI}..."
  LIB_OUTPUT_DIR=${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/lib
  pushd ${LIB_OUTPUT_DIR} > /dev/null

  FFMPEG_ARCHIVES=()
  for arch in libavformat.a libavcodec.a libavfilter.a libswresample.a libswscale.a libavutil.a libavdevice.a; do
    [ -f "$arch" ] && FFMPEG_ARCHIVES+=("$arch")
  done

  EXTERNAL_ARCHIVES=()
  if [ -d "${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib" ]; then
    for ext_a in ${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib/*.a; do
      [ -f "$ext_a" ] && EXTERNAL_ARCHIVES+=("$ext_a")
    done
  fi

  ${FAM_CC} -shared -Wl,-soname,libffmpeg.so \
    -Wl,-z,max-page-size=16384 \
    -Wl,-z,muldefs \
    -Wl,--allow-multiple-definition \
    -Wl,--whole-archive \
    "${FFMPEG_ARCHIVES[@]}" \
    -Wl,--no-whole-archive \
    "${EXTERNAL_ARCHIVES[@]}" \
    ${DEP_LD_FLAGS} \
    -lm -lz -llog -landroid \
    -o libffmpeg.so || exit 1

  # Create libffmpeg.mx.so alias as well
  cp -f libffmpeg.so libffmpeg.mx.so
  echo "==> libffmpeg.so successfully created for ${ANDROID_ABI}!"
  popd > /dev/null
fi
