#!/bin/sh
#
# ghi PS scripts
#

if [ "$1" = "" ] ; then
busybox ps 
else
busybox ps | grep "$1"
fi


