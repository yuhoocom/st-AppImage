#!/bin/sh
set -eu

ARCH=$(uname -m)
VERSION="0.9.3-custom"
export ARCH VERSION

export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY:-local/st}|${GITHUB_REPOSITORY:-local/st}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/702499f331aa9c38309e1af99de4021013916297/Papirus/64x64/apps/st.svg
export DEPLOY_OPENGL=0
export DEPLOY_VULKAN=0
export ANYLINUX_LIB=1
export URUNTIME_PRELOAD=1

quick-sharun /usr/bin/st

# 打包字体到 AppDir
FONTDIR=./AppDir/shared/share/fonts/GoMono
mkdir -p "$FONTDIR"
cp ./fonts/*.ttf "$FONTDIR"/
fc-cache -fv "$FONTDIR" 2>/dev/null || true
echo "Bundled fonts:" && ls -la "$FONTDIR"/

quick-sharun --make-appimage
quick-sharun --test ./dist/*.AppImage
