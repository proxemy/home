{
  pkgs,
  self,
  hostnames,
}:
pkgs.writeShellScript "test_build_all.sh" ''
  set -euo pipefail

  for hostname in ${builtins.toString hostnames}; do
    echo building "$hostname" ...
    nix build \
      --verbose \
      --show-trace \
      "${self}"#nixosConfigurations."$hostname".config.system.build.toplevel
  done
''
