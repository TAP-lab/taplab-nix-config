#!/usr/bin/env bash

set -e

pkill msedge || true

cd ~/.config/microsoft-edge

curl -fsSL http://10.0.0.152:8080/edge -o Default.tar.xz

rm -rf Default

tar -xf Default.tar.xz 

rm Default.tar.xz

echo "Microsoft Edge profile updated."