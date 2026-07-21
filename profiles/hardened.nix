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
    pkexec.setuid = lib.mkForce false;
    sg.enable = false;
    su.enable = false;
    sudoedit.enable = false;
  };

  networking.firewall = {
    logRefusedConnections = true;
    logRefusedPackets = true;
    logReversePathDrops = true;
  };

  nix.settings.allowed-users = [ secrets.username ];

  # breaks alot of desktop apps
  environment.memoryAllocator.provider = lib.mkDefault "graphene-hardened";

  # TODO: load kernel modules required by iptables that are disallowed by 'modules_disabled'
  boot.kernel.sysctl = {
    #"kernel.modules_disabled" = 1;
    "kernel.kptr_restrict" = 2; # hides kernel pointers in /proc, 2 for even root (may break things)
    "kernel.yama.ptrace_scope" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    #"kernel.unprivileged_userns_clone" = 0;

    "net.core.bpf_jit_harden" = 2;
    "user.max_user_namespaces" = 0; # disable user namespaces
    "kernel.kexec_load_disabled" = 1; # disable builtin kexec

    "kernel.printk" = if cfg.debug then 6 else 4;
  };

  boot.kernelParams = [
    "hardened_usercopy=1"
    "slab_nomerge"
    "init_on_alloc=1"
    "init_on_free=1"
    "pti=on"
    "vsyscall=none"
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  system.etc.overlay.mutable = false;
}
