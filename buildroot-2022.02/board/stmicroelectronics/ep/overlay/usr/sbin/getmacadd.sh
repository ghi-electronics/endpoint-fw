#!/bin/sh

ifconfig $1 | grep 'HWaddr' | awk '{print $5}'
