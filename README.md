## TODO

[] Rename mixed cases into snake case: 'cfg.homeDir', 'git-home-repo', etc.
[] Pin down MACs/IPs for all devices in networking and externally in router.
[] Salt script.
[] ACLs for NFS share, services and blob.  
   Apparmor profiles.
[] nix tests before update appliance.
[] Network auditing, carnary.
[] IPsec for known services/hosts.
[] Update flake.lock in auto-update.
[] Create OMPL.
[] Script to partition new RAID drives.
[] Health check: known IP/MAC assigned?
[] create cfg.debug bool and pass it down to crucial services: sshd, nfsd, systemd, auto-update
[] Deprecate either 'output.homeConfigurations.${user_name}' or 'common.nix:imports.home-manager...'.
[] Secrets string scanning in all but 'secrets.nix' nix files.
[] Encrypt RAID drives.
[] Collect dives SMART data and setup alerts and RAID scrub schedule.
