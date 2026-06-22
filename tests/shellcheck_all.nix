{
  pkgs,
  self,
}:
let
  find = "${pkgs.lib.getBin pkgs.findutils}/bin/find";
  shellcheck = "${pkgs.lib.getBin pkgs.shellcheck}/bin/shellcheck";
in
pkgs.writeShellScript "test_shellchek_all.sh"
''
  set -uo pipefail

  sh_files=$(${find} ${self} -iname '*.sh' -type f -executable)

  for f in ''${sh_files[@]}; do
    echo Checking "$f"
    ${shellcheck} "$f"
  done
''
