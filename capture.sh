#!/usr/bin/env sh
adb root
adb push ./out/arm64/tcpdump /data/local/tmp/
adb shell chmod 755 /data/local/tmp/tcpdump
# tcpdump
# -i any: Capture packets on all interfaces.
# -p: Do not put the interface in promiscuous mode (we only want traffic to/from this device)
# -s 0: Capture the full packet (not truncated).
# -U = "unbuffered" PCAP writing (flush every packet)
# -w -: Write packets in pcap format to stdout (i.e., stream them instead of saving to a file).
# wireshark
# -i -: Read from stdin (the pipe from tcpdump).
# -k: Start capturing immediately.
adb shell /data/local/tmp/tcpdump -i any -p -s 0 -U -w - | wireshark -k -i -
