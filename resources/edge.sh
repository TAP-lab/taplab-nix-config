#!/usr/bin/env bash

set -e

pkill msedge
echo "Closed Microsoft Edge."

cd ~/.config/microsoft-edge
echo "Changed directory to Microsoft Edge config."

curl -fsSL http://192.168.1.220:8080/edge -o Default.tar.xz
echo "Downloaded new profile archive."

rm -rf Default
echo "Removed old Default profile."

tar -xf Default.tar.xz 
echo "Extracted new Default profile."

rm Default.tar.xz
echo "Removed profile archive."

microsoft-edge & 
echo "Launched Microsoft Edge with new profile."