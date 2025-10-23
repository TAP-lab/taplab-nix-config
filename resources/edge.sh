#!/usr/bin/env bash

set -e

pkill msedge

cd ~/.config/microsoft-edge

curl -fsSL http://192.168.1.220:8080/edge -o Default.tar.xz

rm -rf Default

tar -xf Default.tar.xz 

rm Default.tar.xz

microsoft-edge & 

exit