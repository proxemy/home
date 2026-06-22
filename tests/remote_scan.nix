{
  pkgs,
  self,
  hostnames,
  hosts,
  #nmap ? "${pkgs.nmap}/bin/nmap"
}:
let
  nixos-rebuild = "${pkgs.nixos-rebuild-ng}/bin/nixos-rebuild";
  nmap = "${pkgs.nmap}/bin/nmap";
in
pkgs.writeShellScript "test_remote_scan.sh" ''
  if [[ ! -z $1 ]]; then
    ${nixos-rebuild} build-vm --flake ${self}#$1
    # TODO scan single target
  else
    # TODO build and scan all host vms
  fi
''
