# ffmpeg-android-maker (MX Player Ultimate Edition)

[![Compilability check](https://github.com/Javernaut/ffmpeg-android-maker/actions/workflows/build.yml/badge.svg)](https://github.com/Javernaut/ffmpeg-android-maker/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.txt)

A powerful, high-performance toolchain script that downloads the source code of [FFmpeg](https://www.ffmpeg.org) and compiles it for **Android**.

Supports building:
1. **MX Player Custom Codec** (`libffmpeg.mx.so`, `libffmpeg.so`, and ready-to-import `mx_aio.zip`) with **all** proprietary audio, video, and subtitle decoders (AC3, EAC3, TrueHD, MLP, DTS, DCA, libass, HEVC, AV1, VP9, MediaCodec HW acceleration).
2. **Modular Shared Libraries** (`libavcodec.so`, `libavformat.so`, `libavutil.so`, `libswresample.so`, `libswscale.so`, `libavfilter.so`) and C/C++ header files for custom Android apps, ExoPlayer FFmpeg extension, ijkplayer, or MediaFile.
3. Standalone Android command-line executables (`ffmpeg` and `ffprobe`).

---

## ⚡ Quick Start: Compile for MX Player (All-In-One Codec)

To compile FFmpeg with **100% MX Player codec coverage** (Dolby Digital AC3/E-AC3, TrueHD, DTS, libass subtitles, MediaCodec, and AIO ZIP packaging):

```bash
./ffmpeg-android-maker.sh --profile=mxplayer -abis=arm64-v8a,armeabi-v7a
```
*or using the convenience shortcut:*
```bash
./tools/build-mxplayer.sh -abis=arm64-v8a,armeabi-v7a
```

When finished, your custom codec files will be ready in the `output/` directory:
- `output/mx_aio.zip` – **All-In-One ZIP** ready to load directly in MX Player!
- `output/mxplayer/<abi>/libffmpeg.mx.so` – Standalone custom codec library for each architecture.
- `output/lib/<abi>/` – Modular shared libraries for Android app development.
- `output/include/<abi>/` – FFmpeg C/C++ headers.

---

## 🎬 How to Use in MX Player

1. Copy `output/mx_aio.zip` to your Android device (e.g. into your `Download` folder).
2. Open **MX Player** on your Android device.
3. Go to **Settings > Decoder** (or Menu → Settings → Decoder).
4. Scroll to the bottom and tap **Custom codec**.
5. Select `mx_aio.zip`.
6. MX Player will confirm and prompt to restart. Tap **OK**.
7. MX Player will show: *"Using custom codec: libffmpeg.mx.so"*.
8. Enjoy seamless playback for EAC3, TrueHD, DTS, 10-bit HEVC, and styled ASS/SSA subtitles!

---

## 🎧 Complete Codec & Decoder Matrix

### 1. Audio Decoders
| Format | Decoder / Component | Notes |
| :--- | :--- | :--- |
| **Dolby Digital** | `ac3`, `ac3_fixed` | 5.1 / 2.0 surround audio |
| **Dolby Digital Plus** | `eac3` | EAC3 / E-AC-3 / Dolby Atmos core |
| **Dolby TrueHD** | `truehd` | Lossless Blu-ray master audio |
| **MLP** | `mlp` | Meridian Lossless Packing / DVD-Audio |
| **DTS / DTS-HD** | `dca` | DTS, DTS-HD MA, DTS-ES, DTS 96/24 |
| **AAC** | `aac`, `aac_latm`, `aac_fixed` | AAC-LC, HE-AAC v1/v2, AAC-LD |
| **Opus** | `opus`, `libopus` | Low-latency and modern streaming |
| **MP3** | `mp3`, `mp3float`, `libmp3lame` | MPEG-1/2 Audio Layer III |
| **FLAC & ALAC** | `flac`, `alac` | Free Lossless Audio & Apple Lossless |
| **Monkey's Audio** | `ape` | High-compression lossless format |
| **WavPack** | `wavpack` | Hybrid lossless/lossy format |
| **Windows Media** | `wmapro`, `wmav1`, `wmav2`, `wmalossless` | WMA standard, professional, and lossless |
| **RealAudio** | `cook`, `ra_144`, `ra_288`, `atrac1`, `atrac3` | RealMedia / ATRAC audio codecs |
| **AMR** | `amrnb`, `amrwb` | Cellular voice audio (Narrowband & Wideband) |
| **DSD / SACD** | `dsd_lsbf`, `dsd_msbf`, `dsd_planar` | Super Audio CD bitstreams |
| **PCM** | `pcm_s16le`, `pcm_s24le`, `pcm_s32le`, `pcm_bluray` | Uncompressed studio audio |

### 2. Video Decoders
| Format | Decoder / Component | Notes |
| :--- | :--- | :--- |
| **HEVC / H.265** | `hevc`, `hevc_mediacodec` | Main, Main10 (10-bit HDR), HW accelerated |
| **AVC / H.264** | `h264`, `h264_mediacodec` | Baseline, Main, High, Hi10P |
| **AV1** | `libdav1d`, `av1_mediacodec` | Modern ultra-fast AV1 playback |
| **VP9 & VP8** | `libvpx`, `vp9_mediacodec`, `vp8_mediacodec` | YouTube and WebM video formats |
| **MPEG-4 Part 2** | `mpeg4`, `mpeg4_mediacodec`, `msmpeg4` | DivX, XviD, MS-MPEG4 |
| **MPEG-1 & MPEG-2** | `mpeg1video`, `mpeg2video` | DVD Video, VOB, DVB broadcasts |
| **VC-1 & WMV** | `vc1`, `wmv1`, `wmv2`, `wmv3` | Windows Media Video & Blu-ray VC-1 |
| **RealVideo** | `rv10`, `rv20`, `rv30`, `rv40` | RMVB video streams |
| **Apple ProRes** | `prores` | High quality ProRes 422, 4444, HQ |
| **Legacy Formats** | `mjpeg`, `theora`, `flv1`, `vp6`, `binkvideo`, `cinepak` | Classic internet video formats |

### 3. Subtitle Decoders & Renderers
| Format | Component | Notes |
| :--- | :--- | :--- |
| **Advanced SSA / ASS** | `libass` + `libfreetype` + `libfribidi` | Anime styled subtitles, positioning, fonts, colors, and karaoke |
| **SubRip (.srt)** | `subrip` | Standard SRT text subtitles |
| **WebVTT (.vtt)** | `webvtt` | HTML5 / HLS streaming text subtitles |
| **HDMV PGS** | `pgssub` | High-definition Blu-ray image subtitles |
| **DVD VobSub** | `dvdsub` | Standard DVD `.sub` / `.idx` image subtitles |
| **DVB Subtitles** | `dvbsub` | European digital TV broadcast subtitles |
| **DVB Teletext** | `teletext` | Broadcast teletext closed captions |
| **MP4 / 3GPP Text** | `mov_text` | QuickTime / MP4 timed text |
| **Others** | `microdvd`, `sami`, `jacosub`, `realtext`, `cc_dec` | Closed captions (EIA-608 / CEA-708) & text |

### 4. Hardware Acceleration
- Android **MediaCodec** decoders enabled for: `h264`, `hevc`, `mpeg4`, `vp8`, `vp9`, `av1`.
- Android **JNI** surface integration.

---

## 🛠️ Command-Line Arguments

| Flag | Description |
| :--- | :--- |
| `--profile=mxplayer` or `-mx` | **Ultimate MX Player Profile**: enables all audio/video/subtitle decoders, MediaCodec, GPL, all free/gpl external libs, builds `libffmpeg.mx.so`, and packages `mx_aio.zip`. |
| `-abis=<list>` | Comma-separated list of ABIs (`arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`). Default: all 4. |
| `--enable-libass` or `-ass` | Enables the `libass` subtitle renderer (auto-includes `libfreetype` and `libfribidi`). |
| `--enable-mediacodec` or `-mediacodec` | Enables Android MediaCodec hardware video acceleration. |
| `--build-mx-so` or `-mx-so` | Links the unified single shared library `libffmpeg.mx.so` (and `libffmpeg.so`). |
| `--package-aio` or `-aio` | Creates the All-In-One ZIP package (`output/mx_aio.zip`). |
| `--enable-all-free` or `-all-free` | Enables all non-GPL external libraries (`libdav1d`, `libopus`, `libvpx`, `libass`, etc.). |
| `--enable-all-gpl` or `-all-gpl` | Enables GPL external libraries (`libx264`, `libx265`). |
| `--android-api-level=<num>` | Minimum Android API level (Default: `21`). |

---

## 💻 Requirements & Environment

1. **Android NDK**: Version **r23** or higher (r25c / r26 recommended).
2. **Environment Variables**:
   - `ANDROID_NDK_HOME` – Path to your Android NDK.
   - `ANDROID_SDK_HOME` (or `ANDROID_HOME` / `ANDROID_SDK_ROOT`) – Path to your Android SDK.
3. **Host Tools**:
   `make`, `cmake`, `curl`, `tar`, `zip`, `unzip`, `nasm`, `ninja`, `meson`, `pkg-config`, `clang`.

---

## 🚀 Automated Cloud Builds (GitHub Actions)

This repository includes a ready-to-run GitHub Actions workflow in `.github/workflows/build.yml`.

Whenever you push to `master` or `main` (or click **Run workflow** under the Actions tab):
1. Sets up Ubuntu 22.04 with Android NDK r25c.
2. Compiles FFmpeg with the complete `--profile=mxplayer` profile for `arm64-v8a` and `armeabi-v7a`.
3. Packages both `mx_aio.zip` and `ffmpeg-android.zip`.
4. Automatically publishes the latest binaries to **GitHub Releases** for direct download!

---

## 📄 License

- **ffmpeg-android-maker** scripts are licensed under the [MIT License](LICENSE.txt).
- FFmpeg itself is licensed under **LGPL 2.1** (or **GPL 2.0+** when GPL features/libraries like `libx264`/`libx265` are enabled).
