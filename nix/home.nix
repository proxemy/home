{ home-manager, config, ... }:
{
	imports = [ home-manager.nixosModules.home-manager ];

	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;

	home-manager.users.leme.home = {
		inherit (config.system) stateVersion;
		homeDirectory = "/home/leme";
		username = "leme";
	};
}
