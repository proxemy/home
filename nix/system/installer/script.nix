{
  pkgs,
  host,
  cfg,
}:
let
  inherit (cfg) home_git_dir;

  partx = "${pkgs.util-linux}/bin/partx";
  wipefs = "${pkgs.util-linux}/bin/wipefs";
  parted = "${pkgs.parted}/bin/parted";
  mkfs = "${pkgs.util-linux}/bin/mkfs";
  mkswap = "${pkgs.util-linux}/bin/mkswap";

  test_confirm_wipe = device: ''
    test -b "${device}" || { echo Target device "${device}" is no block device; exit 1; }
    ${partx} --show ${device}
    echo All data will be lost!
    [[ $(read -p "Proceed? [y|N]:"; echo $REPLY) =~ y|Y ]] || exit 0
    ${wipefs} -a "${device}"
  '';

  mk_primary = partition:
  let
    device = "/dev/disk/by-id/${partition.id}";
  in
  ''
    ${test_confirm_wipe device}
    ${parted} -s "${device}" mklabel ${partition.label}
    ${parted} -s "${device}" -- mkpart primary 1MB -${partition.swap_size}GB
    ${parted} -s "${device}" -- set 1 boot on
    ${parted} -s "${device}" -- mkpart primary linux-swap -${partition.swap_size}GB 100%
    ${mkfs} -t ${partition.fs} -L nixos "${device}-part1"
    ${mkswap} -L swap "${device}-part2"
  '';

  mk_secondary = partition:
  let
    device = "/dev/disk/by-id/${partition.id}";
  in
  ''
    echo TODO
  '';
in
pkgs.writeShellScript "install.sh" ''
  set -xeuo pipefail

  sudo -s <<EOF

  ${mk_primary host.partitions.primary}

  # the host.root_fs.parition script needs to create 2 labeled partitions, nixos and swap
  ${pkgs.util-linux.bin}/bin/mount /dev/disk/by-label/nixos /mnt
  ${pkgs.util-linux.bin}/bin/swapon /dev/disk/by-label/swap

  mkdir -p "/mnt/${home_git_dir}"
  cp -r /iso/home-git/. "/mnt/${home_git_dir}"

  nixos-install \
  --flake "/mnt/${home_git_dir}"#${host.hostname} \
  --root /mnt \
  --no-root-passwd \
  --verbose \
  --show-trace
''
