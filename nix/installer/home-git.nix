{ pkgs, secrets, sourceInfo }: pkgs.stdenv.mkDerivation
{
	name = "initial-home-git";

	nativeBuildInputs = with pkgs; [ git git-crypt ];

	dontUnpack = true;

	buildPhase = ''
		git init --initial-branch=main $out

		cd $out
		git-crypt unlock ${secrets.git-crypt.key-file}

		git remote add origin "https://github.com/proxemy/home"
		git remote set-url --push origin git@github.com:proxemy/home.git

		# since the initial main branch is empty, we cannot set upstream the usual way
		git config branch.main.remote origin
		git config branch.main.merge refs/heads/main

		git config include.path ~/.config/gitconfig/proxemy

		cp --recursive ${sourceInfo}/. $out
		git add . # required, so nixos-install can access all copied files
	'';
}

