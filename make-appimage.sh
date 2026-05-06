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

quick-sharun /usr/bin/st
quick-sharun --make-appimage
quick-sharun --test ./dist/*.AppImage
