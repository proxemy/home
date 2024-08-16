{ home-manager, dotfiles, stateVersion, ... }:
{
	imports = [ home-manager.nixosModules.home-manager ];

	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;

	home-manager.users.leme = {
		home = {
			inherit stateVersion;

			# copy dotfiles into $HOME
			file."/" = {
				source = dotfiles;
				recursive = true;
			};
		};

		programs.git = {
			enable = true;
			#extraConfig.include = { path = "~/.config/gitconfig/proxemy" };
		};
	};
}
