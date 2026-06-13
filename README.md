# My Nixos Homelab

This repositry defines all my private devices. Laptops, desktops, RaspberryPis,
remote servers and maybe some day my smartphones.

## Dependencies

* Secrets are encrypted in `nix/secrets/*`. Without decryption or mocking,
this repository is not reporducible for you.
* External dotfiles repository gets cloned into `$HOME`. These dotfiles are not
managed by nix and get copied blindly.

## TODO

* [ ] ACLs for NFS share, services and blob. Maybe Apparmor profiles.
* [ ] nix tests before update appliance.
* [ ] LAN carnary.
* [ ] IPsec for known services/hosts.
* [x] Update flake.lock in auto-update.
* [x] RSS feeds OPML.
* [x] Script to partition new RAID drives.
* [x] DCHP known IP leased?
* [x] create cfg.debug bool and pass it down to crucial services: sshd, nfsd, systemd, auto-update
* [x] Deprecate either 'output.homeConfigurations.${user_name}' or 'common.nix:imports.home-manager...'.
* [ ] Secrets string scanning in all but 'secrets.nix' nix files.
* [x] Encrypt RAID drives.
* [ ] Collect drives SMART data and setup alerts and RAID scrub schedule.
* [ ] Media server/bridge on raspi + TV.
* [x] Email/thunderbird setup.
* [x] IRC/weechat setup.
* [x] Hardened Systemd service template.
* [ ] Parameterized/Automatic isolated NAS folder creation for every given service
* [x] Full vim IDE setup to replace current manual steps.
* [x] Move `contents = [];` from `installerMedium.nix` to `common.nix`
* [x] Move all nix/installer/* into corresponding nix/system/*.
* [x] Populate the intaller mediums /nix/store with all packages required by target nixos/host to make offline intalls possible
* [ ] Offline installs from installer mediums, see list item above.
* [ ] Raid auto-repair systemd service.
* [ ] Conditional nixos-upgrade.service reboot, so it doesn't interrupt eg. service above.
* [ ] Remote scan / security audit of running services.
* [ ] SIEM. Dedicated, isolated systemd service for aggregated logging.
* [ ] DNS prefetch/cache of known domains (bookmarks, feeds, etc.).
* [ ] Fetch RSS feeds via tor, maybe replace akregator, since it only respects KDE config.
* [ ] Security system + autmoation with smartphone LAN detection.
* [ ] Use local DNS server as system provider and check router for passthru.
* [ ] Optional import of email data into thunderbird. Keep it encrypted separately, not in the nix store.
* [ ] Add air quality sensors to raspi + logging SIEM.
