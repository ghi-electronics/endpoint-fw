#!/bin/sh

dmesg | grep "$1" | tail -1
