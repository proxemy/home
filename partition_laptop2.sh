#!/usr/bin/bash

set -euo pipefail


DISC="${DISC:-$1}"

sudo partx --show "$DISC"

echo "Partitioning disc: '$DISC'! All data will be lost!"
read -p "Proceed? [y/N]:" confirm
[[ "$confirm" =~ y|Y ]] || { echo "Arboting"; exit 0; }

exit # safety

#sudo delpart "$DISC" "$DISC"*
#sudo fdisk "$DISC"

# MBR, 50mb
#sudo addpart "$DISC" 1 0 $((50*1024*1024/512))
#sudo partx -t dos "$DISC"1



