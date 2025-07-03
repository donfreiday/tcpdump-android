#!/usr/bin/env sh
set -e

# Build all targets
docker build --target build-arm64 -t android-tcpdump-arm64 .
docker build --target build-arm32 -t android-tcpdump-arm32 .
docker build --target build-x86_64 -t android-tcpdump-x86_64 .

# Create output dirs
mkdir -p out/arm64 out/arm32 out/x86_64

# Extract binaries
docker run --rm -v "$(pwd)/out/arm64:/out" android-tcpdump-arm64 cp /build/tcpdump/tcpdump /out/tcpdump
docker run --rm -v "$(pwd)/out/arm32:/out" android-tcpdump-arm32 cp /build/tcpdump/tcpdump /out/tcpdump
docker run --rm -v "$(pwd)/out/x86_64:/out" android-tcpdump-x86_64 cp /build/tcpdump/tcpdump /out/tcpdump