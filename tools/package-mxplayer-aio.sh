#!/usr/bin/env bash

# Convenience wrapper to package output into MX Player AIO ZIP
BASE_DIR="$( cd "$( dirname "$0" )/.." && pwd )"
"${BASE_DIR}/scripts/package-mxplayer-aio.sh" "$@"
