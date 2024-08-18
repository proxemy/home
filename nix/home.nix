{ stateVersion, dotfiles, home-manager, ... }:
{
	home = {
		inherit stateVersion;

		username = "leme";
		homeDirectory = "/home/leme";

		activation.copy-dotfiles = home-manager.lib.hm.dag.entryAfter [ "linkGeneration" ] ''
			cp -r ${dotfiles.outPath}/* "$HOME"/
		'';
	};

	programs.git = {
		enable = true;
		#extraConfig.include = { path = "~/.config/gitconfig/proxemy" };
	};
}
