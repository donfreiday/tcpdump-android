# Build tcpdump for Android based on instructions here https://www.androidtcpdump.com/android-tcpdump/compile

FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    make byacc flex git autoconf automake libtool \
    pkg-config wget curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

FROM base AS source

RUN git clone https://github.com/the-tcpdump-group/libpcap.git && \
    git clone https://github.com/the-tcpdump-group/tcpdump.git

FROM base AS build-arm64

RUN apt-get update && apt-get install -y gcc-aarch64-linux-gnu

ENV CC=aarch64-linux-gnu-gcc \
    ac_cv_linux_vers=2 \
    CFLAGS=-static \
    CPPFLAGS=-static \
    LDFLAGS=-static

WORKDIR /build

COPY --from=source /src/libpcap ./libpcap
RUN cd libpcap && autoreconf -i && \
    ./configure --host=arm-linux --with-pcap=linux --disable-shared --enable-static && \
    make

COPY --from=source /src/tcpdump ./tcpdump
RUN cd tcpdump && autoreconf -i && \
    ./configure --host=arm-linux --disable-ipv6 --disable-shared --enable-static && \
    make && aarch64-linux-gnu-strip tcpdump

FROM base AS build-arm32

RUN apt-get update && apt-get install -y gcc-arm-linux-gnueabi

ENV CC=arm-linux-gnueabi-gcc \
    ac_cv_linux_vers=2 \
    CFLAGS=-static \
    CPPFLAGS=-static \
    LDFLAGS=-static

WORKDIR /build

COPY --from=source /src/libpcap ./libpcap
RUN cd libpcap && autoreconf -i && \
    ./configure --host=arm-linux --with-pcap=linux --disable-shared --enable-static && \
    make

COPY --from=source /src/tcpdump ./tcpdump
RUN cd tcpdump && autoreconf -i && \
    ./configure --host=arm-linux --disable-ipv6 --disable-shared --enable-static && \
    make && arm-linux-gnueabi-strip tcpdump

FROM base AS build-x86_64

RUN apt-get update && apt-get install -y gcc-x86-64-linux-gnu

ENV CC=x86_64-linux-gnu-gcc \
    ac_cv_linux_vers=2 \
    CFLAGS=-static \
    CPPFLAGS=-static \
    LDFLAGS=-static

WORKDIR /build

COPY --from=source /src/libpcap ./libpcap
RUN cd libpcap && autoreconf -i && \
    ./configure --host=x86_64-linux --with-pcap=linux --disable-shared --enable-static && \
    make

COPY --from=source /src/tcpdump ./tcpdump
RUN cd tcpdump && autoreconf -i && \
    ./configure --host=x86_64-linux --disable-ipv6 --disable-shared --enable-static && \
    make && x86_64-linux-gnu-strip tcpdump
