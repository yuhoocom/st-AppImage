#!/bin/sh
set -eu

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm base-devel libx11 libxft fontconfig freetype2 \
    ncurses pkg-config git

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building st from source..."
echo "---------------------------------------------------------------"

git clone https://git.suckless.org/st /tmp/st-src
cd /tmp/st-src
git checkout "$(git describe --tags --abbrev=0 2>/dev/null || echo master)"

cp config.def.h config.h
sed -i 's|int allowwindowops = 0;|int allowwindowops = 1;|' config.h
sed -i 's|pixelsize=12|pixelsize=32|' config.h

make clean
make PREFIX=/usr
make PREFIX=/usr install
tic -sx st.info

cd /
rm -rf /tmp/st-src
