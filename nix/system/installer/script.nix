{
  pkgs,
  host,
  cfg,
}:
let
  inherit (cfg) home_git_dir;
in
pkgs.writeShellScript "install.sh" ''
  set -euo pipefail

  test -b '${host.root_fs.device}' || { echo Illegal target device: ${host.root_fs.device}; exit 1; }

  ${pkgs.util-linux.bin}/bin/partx --show '${host.root_fs.device}'

  echo Partitioning disc: '${host.root_fs.device}'! All data will be lost!
  read -p "Proceed? [y/N]:" confirm
  [[ "$confirm" =~ y|Y ]] || { echo "Arborting"; exit 0; }

  set -x

  ${pkgs.util-linux.bin}/bin/wipefs '${host.root_fs.device}'

  ${host.root_fs.partition_script pkgs}

  set +x

  # the host.root_fs.parition script needs to create 2 labeled partitions, nixos and swap
  ${pkgs.util-linux.bin}/bin/mount /dev/disk/by-label/nixos /mnt
  ${pkgs.util-linux.bin}/bin/swapon /dev/disk/by-label/swap

  mkdir -p "\mnt\${home_git_dir}"
  cp -r /iso/home-git/. "\mnt\${home_git_dir}"

  nixos-install \
  --flake "\mnt\${home_git_dir}"#${host.hostname} \
  --root /mnt \
  --no-root-passwd \
  --verbose \
  --show-trace
''
