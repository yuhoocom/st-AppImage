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

# ── 应用 fullscreen patch（F11 / Alt+Enter 切换全屏）──             # ← NEW
# patch 修改 config.def.h（添加快捷键）和 x.c（添加函数）            # ← NEW
# 必须在 cp config.def.h config.h 之前执行                           # ← NEW
curl -fsSL "https://st.suckless.org/patches/fullscreen/st-fullscreen-0.8.5.diff" \
  -o /tmp/st-fullscreen.diff                                         # ← NEW
patch -p1 < /tmp/st-fullscreen.diff \
  || { echo "FATAL: fullscreen patch failed"; exit 1; }              # ← NEW

cp config.def.h config.h
sed -i 's|int allowwindowops = 0;|int allowwindowops = 1;|' config.h
sed -i 's|pixelsize=12|pixelsize=32|' config.h

# ── 验证所有自定义改动是否生效 ──                                   # ← NEW
grep 'allowwindowops = 1' config.h \
  || { echo "FATAL: allowwindowops sed failed"; exit 1; }            # ← NEW
grep 'pixelsize=32' config.h \
  || { echo "FATAL: pixelsize sed failed"; exit 1; }                 # ← NEW

make clean
make PREFIX=/usr
make PREFIX=/usr install
tic -sx st.info

cd /
rm -rf /tmp/st-src
