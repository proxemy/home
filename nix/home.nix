{ stateVersion, dotfiles, ... }:
{
	home = {
		inherit stateVersion;

		username = "leme";
		homeDirectory = "/home/leme";

		# copy dotfiles into $HOME
		file."/" = {
			source = dotfiles.outPath;
			recursive = true;
		};
	};

	programs.git = {
		enable = true;
		#extraConfig.include = { path = "~/.config/gitconfig/proxemy" };
	};
}
