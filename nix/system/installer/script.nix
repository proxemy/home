{
  pkgs,
  host,
  cfg,
}:
let
  inherit (cfg) home_git_dir;

  str = builtins.toString;

  partx = "${pkgs.util-linux}/bin/partx";
  wipefs = "${pkgs.util-linux}/bin/wipefs";
  mkfs = "${pkgs.util-linux}/bin/mkfs";
  mkswap = "${pkgs.util-linux}/bin/mkswap";
  mount = "${pkgs.util-linux}/bin/mount";
  parted = "${pkgs.parted}/bin/parted";
  cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";

  test_confirm_wipe = device: ''
    # TEST CONFIRM WIPE
    test -b "${device}" || { echo Target device "${device}" is no block device; exit 1; }
    sudo ${partx} --show ${device} || true
    echo All data will be lost!
    [[ $(read -p "Proceed? [y|N]:"; echo $REPLY) =~ y|Y ]] || exit 0
    sudo ${wipefs} --all "${device}" || true
  '';

  mk_primary =
    partition:
    let
      device = "/dev/disk/by-id/${partition.id}";

      mk_msdos = ''
        # MK_MSDOS
        sudo ${parted} -s "${device}" -- mklabel msdos
        sudo ${parted} -s "${device}" -- mkpart primary "nixos" 0% 100%
        sudo ${parted} -s "${device}" -- set 1 boot on
        sudo ${mkfs} -t ${partition.fs} -L nixos /dev/disk/by-partlabel/nixos
      '';

      mk_efi = ''
        # MK_EFI
        sudo ${parted} -s "${device}" -- mklabel gpt
        sudo ${parted} -s "${device}" -- mkpart "boot" fat32 1MB 100MB
        sudo ${parted} -s "${device}" -- set 1 esp on
        sudo ${parted} -s "${device}" -- mkpart "nixos" ${partition.fs} 100MB 100%
        sudo ${mkfs} -t fat -F 32 -n boot /dev/disk/by-partlabel/boot
        sudo ${mkfs} -t ${partition.fs} -L nixos /dev/disk/by-partlabel/nixos
      '';
    in
    ''
      # MK_PRIMARY

      ${test_confirm_wipe device}

      ${if partition.efi then mk_efi else mk_msdos}

      ${
        if partition.encrypt then
          ''
            sudo ${cryptsetup} luksFormat --label="cryptroot" /dev/disk/by-partlabel/nixos
            sudo ${cryptsetup} luksOpen /dev/disk/by-partlabel/nixos cryptroot
            sudo mkfs -t ${partition.fs} -L "nixos" /dev/mapper/cryptroot
          ''
        else
          ""
      }
    '';

  mk_secondary =
    partition:
    let
      device = "/dev/disk/by-id/${partition.id}";
    in
    ''
      # MK_SECONDARY

      ${test_confirm_wipe device}

      sudo mkfs -t ${partition.fs} -L "data" "${device}"
    '';

  mk_home_git_dir = ''
    # MK_HOME_GIT_DIR
    sudo mkdir -p "/mnt/${home_git_dir}"
    sudo cp -r /iso/home-git/. "/mnt/${home_git_dir}"
    sudo chown root:root -R "/mnt/${home_git_dir}"
  '';

  mk_swapfile =
    size:
    let
      #device = (builtins.elemAt self.outputs.nixosConfigurations.${host.hostname}.config.swapDevices 0).device;
      # TODO: read swapfile location from target nixos configuration, not hard coded like this.
      swap = "/mnt/.swapfile";
    in
    ''
      # MK_SWAPFILE
      sudo touch "${swap}"
      sudo dd if=/dev/zero of="${swap}" bs=1M count=${str (size * 1024)}
      sudo chmod 600 "${swap}"
      sudo ${mkswap} "${swap}"
    '';
in
pkgs.writeShellScript "install.sh" ''
  set -xeuo pipefail

  ${mk_primary host.partitions.primary}

  ${
    if builtins.hasAttr "secondary" host.partitions then mk_secondary host.partitions.secondary else ""
  }

  sudo ${mount} /dev/disk/by-label/nixos /mnt

  if [[ -b /dev/disk/by-label/boot ]]; then
    sudo mkdir -p /mnt/boot
    sudo mount /dev/disk/by-label/boot /mnt/boot
  fi

  ${mk_swapfile host.swap_size}

  ${mk_home_git_dir}

  sudo nixos-install \
    --flake "/mnt/${home_git_dir}"#${host.hostname} \
    --root /mnt \
    --no-root-passwd \
    --verbose \
    --show-trace
''
