{...}: {
	boot= {
		supportedFilesystems = [ "ext4" ];
		loader.grub = {
			device = "/dev/sda";
			enable = true;
		};
	};

	fileSystems = {
		"/" = {
			device = "/dev/disk/by-label/nixos";
			fsType = "ext4";
			options = [ "noatime" ];
		};
	};

	swapDevices = [{ label = "swap"; }];

	users.users.leme = {
		isNormalUser = true;
		extraGroups = [ "wheel" ];
		initialPassword = "asd";
		createHome = true;
		#openssh.authorizedKeys = [ "TODO" ];
	};

	networking.hostName = "laptop2";

	services = {
		xserver = {
			enable = true;
			desktopManager.xfce.enable = true;
		};
		displayManager.defaultSession = "xfce";
	};
}
