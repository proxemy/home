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
- [ ] Salt script.
- [ ] ACLs for NFS share, services and blob. Maybe Apparmor profiles.
- [ ] nix tests before update appliance.
- [ ] Network auditing, carnary.
- [ ] IPsec for known services/hosts.
- [x] Update flake.lock in auto-update.
- [x] Create OMPL.
- [x] Script to partition new RAID drives.
- [ ] Health check: known IP/MAC assigned?
- [ ] create cfg.debug bool and pass it down to crucial services: sshd, nfsd, systemd, auto-update
- [ ] Deprecate either 'output.homeConfigurations.${user_name}' or 'common.nix:imports.home-manager...'.
- [ ] Secrets string scanning in all but 'secrets.nix' nix files.
- [x] Encrypt RAID drives.
- [ ] Collect drives SMART data and setup alerts and RAID scrub schedule.
- [ ] Media server/bridge on raspi.
