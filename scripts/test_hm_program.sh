#!/usr/bin/env bash

# just a little helper iterate quickly over new program configs

set -euo pipefail

#PROG="firefox"
#CFG_DIR=".config/mozilla/firefox"

#PROG="thunderbird"
#CFG_DIR=".thunderbird"

PROG="${PROG:-$1}"
CFG_DIR="${CFG_DIR:-$2}"

FLAKE_DIR=$(dirname "${BASH_SOURCE[0]}")/.. # base dir of flake, not of scripts/

kill "$(pidof "$PROG")" || true

set -x
rm -rf "${HOME:?}"/"$CFG_DIR"
nix build "$FLAKE_DIR"#nixosConfigurations."$HOSTNAME".config.home-manager.users."$USER".home-files
cp -r "$FLAKE_DIR"/result/"$CFG_DIR" "$HOME"/"$CFG_DIR"
chmod -R a=,u+rwx "$HOME"/"$CFG_DIR"
set +x

#"$HOME"/.config/mozilla/firefox/default/extensions/\{ec8030f7-c20a-464f-9b0e-13a3a9e97384\}/uMatrix@raymondhill.net.xpi \
#export MOZ_LOG=AddonManager:5,XPIProvider:5,addons.xpi:5,addons.manager:5

read -rp "continue?"

"$PROG" &
