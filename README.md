# My Nixos Homelab

This repositry defines all my private devices. Laptops, desktops, RaspberryPis
and maybe some day my smartphone.

## Dependencies

* Secrets are encrypted in `nix/secrets/*`. Without decryption or mocking,
this repository is not reporducible for you.
* External dotfiles repository gets cloned into `$HOME`. These dotfiles are not
managed by nix and get copied blindly.

## TODO

- [x] Pin down MACs/IPs for all devices.
- [x] Salt script.
- [ ] ACLs for NFS share, services and blob. Maybe Apparmor profiles.
- [ ] nix tests before update appliance.
- [ ] Network auditing, carnary.
- [ ] IPsec for known services/hosts.
- [x] Update flake.lock in auto-update.
- [x] Create OPML.
- [x] Script to partition new RAID drives.
- [ ] Health check: known IP/MAC assigned?
- [ ] create cfg.debug bool and pass it down to crucial services: sshd, nfsd, systemd, auto-update
- [ ] Deprecate either 'output.homeConfigurations.${user_name}' or 'common.nix:imports.home-manager...'.
- [ ] Secrets string scanning in all but 'secrets.nix' nix files.
- [x] Encrypt RAID drives.
- [ ] Collect drives SMART data and setup alerts and RAID scrub schedule.
- [ ] Media server/bridge on raspi.
- [ ] Email/thunderbird setup.
- [ ] IRC/weechat setup.
- [ ] Hardened Systemd service template.
- [ ] Parameterized/Automatic isolated NAS folder creation for every given service
- [ ] Service to rsync a list of backup targets onto NAS.
- [ ] Full vim IDE setup to replace current manual steps.
- [ ] Move `contents = [];` from `installerMedium.nix` to `common.nix`
- [ ] Move all nix/installer/* into corresponding nix/system/*.
- [ ] Populate the intaller mediums /nix/store with all packages required by target nixos/host to make offline intalls possible
- [ ] Offline installs from installer mediums, see list item above.
