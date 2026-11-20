#!/bin/sh
# rsh — быстрая установка из GitHub Releases (собранный бинарь, без сборки на устройстве).
#   curl -fsSL https://raw.githubusercontent.com/Zenoku-Dev/rsh/main/install.sh | sh
# Перемённые: RSH_INSTALL_DIR (каталог назначения), RSH_INSTALL_TAG (тег, по умолчанию latest).
set -eu

GH="https://github.com/Zenoku-Dev/rsh/releases"
TAG="${RSH_INSTALL_TAG:-latest}"
URL_BASE="$GH/$TAG/download"

os="$(uname -s 2>/dev/null || echo unknown)"
arch="$(uname -m 2>/dev/null || echo unknown)"
android=no
if [ -n "${PREFIX:-}" ] || [ -n "${TERMUX_VERSION:-}" ] || [ -d /data/data/com.termux ]; then
  android=yes
fi
case "$os:$arch" in
  Linux:x86_64|Linux:amd64) ASSET=rsh-linux-amd64; EXT="" ;;
  Linux:aarch64|Linux:arm64)
    if [ "$android" = yes ]; then ASSET=rsh-android-arm64; else ASSET=rsh-linux-arm64; fi
    EXT="" ;;
  Linux:armv7l|Linux:armv6l|Linux:arm)
    ASSET=rsh-linux-arm; EXT=""
    if [ "$android" = yes ]; then
      echo "rsh: Android arm32:静态 linux/arm может не запускаться под Termux (SELinux)." >&2
      echo "     Для redmi используй ~/bin/zenoku-upd.sh (установщик релиза не собирает)." >&2
    fi ;;
  MINGW*:*|MSYS*:*|CYGWIN*:*) ASSET=rsh-windows-amd64.exe; EXT=".exe" ;;
  *) echo "rsh: нет готового ассета для $os/$arch. Список: https://github.com/Zenoku-Dev/rsh/releases" >&2; exit 1 ;;
esac

if [ -n "${RSH_INSTALL_DIR:-}" ]; then
  DESTDIR="$RSH_INSTALL_DIR"
elif [ "$(id -u 2>/dev/null || echo 1000)" = "0" ] && [ "$android" = no ]; then
  DESTDIR=/usr/local/bin
else
  DESTDIR="$HOME/.local/bin"
fi
mkdir -p "$DESTDIR"
DEST="$DESTDIR/rsh$EXT"

TMPDIR_BASE="${TMPDIR:-${PREFIX:-/tmp}/tmp}"
TMPDIR_BASE="${TMPDIR_BASE:-/tmp}"
mkdir -p "$TMPDIR_BASE" 2>/dev/null || TMPDIR_BASE=/tmp
TMP="$TMPDIR_BASE/rsh-install.$$$EXT"
trap 'rm -f "$TMP"' EXIT INT TERM

echo "rsh: скачиваю $ASSET ($TAG)…"
if ! curl -fL --retry 2 --connect-timeout 15 --max-time 300 -o "$TMP" "$URL_BASE/$ASSET"; then
  echo "rsh: скачивание не удалось" >&2
  exit 1
fi
chmod 755 "$TMP"

# sanity: готовый бинарь обязан уметь напечатать баннер (ловит битые/чужой архитектуры)
BANNER="$("$TMP" -h 2>&1 | head -1 || true)"
case "$BANNER" in
  rsh*) : ;;
  *) echo "rsh: подкачанный бинарь не запускается ($ASSET). Старый файл не тронут." >&2; exit 1 ;;
esac

if [ -f "$DEST" ]; then
  cp -a "$DEST" "$DEST.bak-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
fi
install -m 755 "$TMP" "$DEST"
echo "rsh: установлен $DEST ($BANNER)"
echo "rsh: положи ~/.rsh/{id,id.pub,config.json,.device_token} (или скопируй с dev), затем: rsh vps hostname"
