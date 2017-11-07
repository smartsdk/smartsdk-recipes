#!/bin/sh
# Edit these with the IPs of your deployment
export IOTA_CB_HOST=192.168.99.100
export IOTA_CB_PORT=1026

export IOTA_HOST=192.168.99.100
export IOTA_NORTH_PORT=4041

export ORION_EP=$IOTA_CB_HOST:$IOTA_CB_PORT
export IOTA_EP=$IOTA_HOST:$IOTA_NORTH_PORT