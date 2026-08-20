{
  pkgs,
  lib,
  modulesPath,
  cfg,
  secrets,
  ...
}:
{
  security = {
    #auditd.enable = true;
    apparmor.enable = true;
    polkit.enable = true;

    sudo.enable = false;
    run0 = {
      enable = true;
      enableSudoAlias = true;
    };
  };

  security.wrappers = {
    chsh.enable = false;
    fusermount.enable = false;
    fusermount3.enable = false;
    newgidmap.setuid = false;
    newgrp.setuid = lib.mkForce false;
    newuidmap.setuid = false;
    pkexec.setuid = false;
    sg.enable = false;
    su.enable = false;
    sudoedit.enable = false;
  };

  security.polkit = {
    enablePkexecWrapper = false;
    extraArgs = lib.optionals cfg.debug [
      "--debug"
      "--log-level=debug"
    ];
    #adminIdentities = [ ];
  };

  networking = {
    #enableIPv6 = false;

    firewall = {
      logRefusedConnections = true;
      logRefusedPackets = true;
      logReversePathDrops = true;
    };
  };

  nix.settings.allowed-users = [ secrets.username ];

  # breaks alot of desktop apps
  # nix apparently has a double free caught by graphene-hardened, while auto-updating
  # fallback to libc
  #environment.memoryAllocator.provider = lib.mkDefault "graphene-hardened";

  # TODO: load kernel modules required by iptables that are disallowed by 'modules_disabled'
  boot.kernel.sysctl = {
    #"kernel.modules_disabled" = 1; # add + vm-test conditional virtio_gpu
    "kernel.kptr_restrict" = 2; # hides kernel pointers in /proc, 2 for even root (may break things)
    "kernel.yama.ptrace_scope" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    #"kernel.unprivileged_userns_clone" = 0;

    "net.core.bpf_jit_harden" = 2;
    "net.ipv6.conf.all.accept_ra" = 0; # drop ipv6 router advertisements
    #"user.max_user_namespaces" = 0; # disable user namespaces
    "kernel.kexec_load_disabled" = 1; # disable builtin kexec

    "kernel.printk" = if cfg.debug then 6 else 4;
  };

  boot.kernelParams = [
    "hardened_usercopy=1"
    "slab_nomerge"
    #"init_on_alloc=1" # zero out on alloc/free
    #"init_on_free=1"
    "pti=on"
    "vsyscall=none"
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.tmp.cleanOnBoot = true;

  system.etc.overlay.mutable = false;
}
