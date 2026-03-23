#!/usr/bin/env bash

TMP=$(mktemp -d)
trap '[ -n "$TMP" ] && rm -rf "$TMP"' EXIT

echo "Installing rozipinfo to temporary venv..."
python3 -m venv "$TMP/venv"
"$TMP/venv/bin/pip" install -q rozipinfo
if [ $? -ne 0 ]; then
    echo "Unable to install rozipinfo. Aborting."
    exit 1
fi

echo "Find IOMD ROM nightly download URL..."
ROM_ZIP=$(wget -qO- 'https://www.riscosopen.org/content/downloads/riscpc' | \
            grep -oP '(?<=<a name="beta_iomd_softload" href=")[^"]+')
if [[ -z "$ROM_ZIP" ]]; then
    echo "ROM zip not discovered. Aborting."
    exit 1
fi

echo "Downloading ROM..."
wget -qO "$TMP/rom.zip" "https://www.riscosopen.org$ROM_ZIP"
if [ $? -ne 0 ]; then
    echo "Unable to download ROM zip. Aborting."
    exit 1
fi

echo "Downloading HardDisc4..."
wget -qO "$TMP/harddisc4.zip" 'https://www.riscosopen.org/zipfiles/platform/common/HardDisc4.zip'
if [ $? -ne 0 ]; then
    echo "Unable to download HardDisc4 zip. Aborting."
    exit 1
fi

rm -rf ro5-nightly
mkdir -p ro5-nightly/roms
mkdir -p ro5-nightly/hostfs

echo "Extracting ROM..."
unzip -q -j "$TMP/rom.zip" 'soft/!Boot/Resources/SoftLoad/riscos' -d ro5-nightly/roms

echo "Extracing HardDisc4..."
"$TMP/venv/bin/python3" -m rozipfile -C "$TMP" -e "$TMP/harddisc4.zip"
rsync -a "$TMP/HardDisc4/"* ro5-nightly/hostfs

chmod -R a+rX ro5-nightly

RO_VERSION=$(strings ro5-nightly/roms/riscos | grep -oP 'RISC OS \K[0-9]+\.[0-9]+' | head -1)
RO_DATE=$(strings ro5-nightly/roms/riscos | grep -oP 'Shared C Library.*\[\K[^\]]+' | head -1)
echo "ROM version: RISC OS $RO_VERSION ($RO_DATE)"