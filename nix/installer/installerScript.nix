{
  pkgs,
  host,
  cfg,
}:
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

  mkdir -p "${cfg.home_dir}"
  cp -r /iso/home-git/. "${cfg.home_dir}"

  nixos-install \
  --flake "${cfg.home_dir}"#$(${host.hostname}) \
  --root /mnt \
  --no-root-passwd \
  --verbose \
  --show-trace
''
