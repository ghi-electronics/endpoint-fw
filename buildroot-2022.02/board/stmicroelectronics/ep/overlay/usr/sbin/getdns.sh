#!/bin/sh

cat /etc/resolv.conf|grep -im 1 '^nameserver' |cut -d ' ' -f2
