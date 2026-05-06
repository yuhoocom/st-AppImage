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

# 启用 OSC 52 剪贴板（默认被安全策略关闭）
sed -i 's|int allowwindowops = 0;|int allowwindowops = 1;|' config.h

# GoMono Nerd Font Mono, pixelsize=32 适配 4K 无缩放
sed -i 's|static char \*font = .*|static char *font = "GoMono Nerd Font Mono:pixelsize=32:antialias=true:autohint=true";|' config.h

make clean
make PREFIX=/usr
make PREFIX=/usr install
tic -sx st.info

cd /
rm -rf /tmp/st-src
