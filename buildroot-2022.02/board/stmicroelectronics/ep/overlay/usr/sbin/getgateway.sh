#!/bin/sh

ip route show default | awk '{print $3}'
