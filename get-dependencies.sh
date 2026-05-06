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

# --------------------------------- PATCHES ---------------------------------
# ── add fullscreen patch (F11 / Alt+Enter toggle fullscreen) ──
curl -fsSL "https://st.suckless.org/patches/fullscreen/st-fullscreen-0.8.5.diff" \
  -o /tmp/st-fullscreen.diff
patch -p1 < /tmp/st-fullscreen.diff \
  || { echo "FATAL: fullscreen patch failed"; exit 1; }

# ── add gruvbox dark theme patch ──
curl -fsSL "https://st.suckless.org/patches/gruvbox/st-gruvbox-dark-0.8.5.diff" \
  -o /tmp/st-gruvbox-dark.diff
patch -p1 < /tmp/st-gruvbox-dark.diff \
  || { echo "FATAL: gruvbox patch failed"; exit 1; }

# PENDING...
# ── add scrollback patch (Shift + PageUp / PageDown) ──
# curl -fsSL "https://st.suckless.org/patches/scrollback/st-scrollback-0.9.2.diff" \
#   -o /tmp/st-scrollback.diff
# patch -p1 < /tmp/st-scrollback.diff \
#   || { echo "FATAL: scrollback patch failed"; exit 1; }
# ---------------------------------------------------------------------------

cp config.def.h config.h
sed -i 's|int allowwindowops = 0;|int allowwindowops = 1;|' config.h
sed -i 's|pixelsize=12|pixelsize=32|' config.h

# PENDING
# --- add scrollback keybind ---
# grep -q kscrollup config.h || sed -i '/static Shortcut shortcuts\[\] = {/a\
# \t{ ShiftMask, XK_Page_Up,   kscrollup,   {.i = -1} },\
# \t{ ShiftMask, XK_Page_Down, kscrolldown, {.i = -1} },' config.h

# ── verify changes ──
grep 'allowwindowops = 1' config.h \
  || { echo "FATAL: allowwindowops sed failed"; exit 1; }
grep 'pixelsize=32' config.h \
  || { echo "FATAL: pixelsize sed failed"; exit 1; }
grep 'kscrollup' config.h \
  || { echo "FATAL: scrollback keybind missing"; exit 1; }

make clean
make PREFIX=/usr
make PREFIX=/usr install
tic -sx st.info

cd /
rm -rf /tmp/st-src
