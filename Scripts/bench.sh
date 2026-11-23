#!/usr/bin/env bash
#
# Reproducible build/test benchmarks for PeerTubeSwift.
#
# Builds target a concrete simulator so only the active architecture (arm64) is
# compiled. `generic/platform=iOS Simulator` would additionally build x86_64 and
# roughly double every clean-build number.
#
# Usage:
#   Scripts/bench.sh clean
#   Scripts/bench.sh incremental [path/to/File.swift]
#   Scripts/bench.sh test
#
# Environment:
#   BENCH_DIR   Directory for derived data and logs (default: $TMPDIR/peertube-bench)
#   SIMULATOR   Simulator name used for builds and tests (default: iPhone 17)
#
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

MODE="${1:-clean}"
INCREMENTAL_FILE="${2:-PeerTubeSwift/Views/Feed.swift}"
SIMULATOR="${SIMULATOR:-iPhone 17}"

BENCH_DIR="${BENCH_DIR:-${TMPDIR:-/tmp}/peertube-bench}"
DERIVED_DATA="$BENCH_DIR/DerivedData"
LOG_DIR="$BENCH_DIR/Logs"

DESTINATION="platform=iOS Simulator,name=$SIMULATOR"

mkdir -p "$LOG_DIR"

timestamp() {
  date "+%Y%m%d-%H%M%S"
}

# Runs xcodebuild, tees the output to a log, and always appends a wall-clock
# summary line so a failing run is still measurable.
run_xcodebuild() {
  local label="$1"
  shift
  local log="$LOG_DIR/${label}-$(timestamp).log"
  local start end status

  start="$(date +%s)"

  echo "==> $label"
  echo "    log: $log"
  echo

  xcodebuild "$@" 2>&1 | tee "$log"
  status="${PIPESTATUS[0]}"

  end="$(date +%s)"

  {
    echo
    echo "==> $label finished: $((end - start))s, exit $status"
  } | tee -a "$log"

  return "$status"
}

BUILD_ARGS=(
  -project PeerTubeSwift.xcodeproj
  -scheme PeerTubeSwift
  -configuration Debug
  -destination "$DESTINATION"
  -derivedDataPath "$DERIVED_DATA"
  -skipMacroValidation
  -showBuildTimingSummary
  build
)

status=0

case "$MODE" in
  clean)
    echo "==> removing derived data: $DERIVED_DATA"
    rm -rf "$DERIVED_DATA"
    run_xcodebuild "clean-build" "${BUILD_ARGS[@]}" || status=$?
    ;;
  incremental)
    if [[ ! -f "$INCREMENTAL_FILE" ]]; then
      echo "error: file not found: $INCREMENTAL_FILE" >&2
      exit 1
    fi
    echo "==> touching $INCREMENTAL_FILE"
    touch "$INCREMENTAL_FILE"
    run_xcodebuild "incremental-build" "${BUILD_ARGS[@]}" || status=$?
    ;;
  test)
    run_xcodebuild "test" \
      -project PeerTubeSwift.xcodeproj \
      -scheme PeerTubeSwift \
      -configuration Debug \
      -destination "$DESTINATION" \
      -derivedDataPath "$DERIVED_DATA" \
      -skipMacroValidation \
      -only-testing:PeerTubeSwiftTests \
      test || status=$?
    ;;
  *)
    echo "usage: $0 {clean|incremental [file]|test}" >&2
    exit 1
    ;;
esac

exit "$status"
