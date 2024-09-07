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
    ${git}/bin init --initial-branch=main $out
    cd $out

    ${git-crypt}/bin unlock ${secrets.git-crypt.key-file}

    ${git}/bin remote add origin "https://github.com/proxemy/home"
    ${git}/bin remote set-url --push origin git@github.com:proxemy/home.git

    # since the initial main branch is empty, we cannot set upstream the usual way
    ${git}/bin config branch.main.remote origin
    ${git}/bin config branch.main.merge refs/heads/main

    ${git}/bin config include.path ~/.config/gitconfig/proxemy

    cp --recursive ${sourceInfo}/. $out
    ${git}/bin add . # required, so nixos-install can access tracked files
  '';
}
