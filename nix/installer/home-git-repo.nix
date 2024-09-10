{
  pkgs,
  secrets,
  sourceInfo,
}:
pkgs.stdenv.mkDerivation {
  name = "initial-home-git";

  nativeBuildInputs = with pkgs; [
    git
    git-crypt
  ];

  dontUnpack = true;

  buildPhase = with pkgs; ''
    ${git}/bin/git init --initial-branch=main $out
    cd $out

    ${git-crypt}/bin/git-crypt unlock ${secrets.git-crypt.key-file}

    ${git}/bin/git remote add origin "https://github.com/proxemy/home"
    ${git}/bin/git remote set-url --push origin git@github.com:proxemy/home.git

    # since the initial main branch is empty, we cannot set upstream the usual way
    ${git}/bin/git config branch.main.remote origin
    ${git}/bin/git config branch.main.merge refs/heads/main

    ${git}/bin/git config include.path ~/.config/gitconfig/proxemy

    cp --recursive ${sourceInfo}/. $out
    ${git}/bin/git add . # required, so nixos-install can access tracked files
  '';
}
