{ pkgs, lib, modulesPath, secrets, sourceInfo, /*laptop2, dotfiles*/ ... }:
{
	imports = [
		"${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
		./../common.nix
	];

	#installer.cloneConfigIncludes = [ "./common.nix" ];
	#nix.nixPath = [ "nixos-config=github:proxemy/home" ];
	#system = {
		#copySystemConfiguration = true;
		#nixos-generate-config.configuration = "asd wert";
	#};

	isoImage = {
		edition = lib.mkForce "laptop2";
		isoBaseName = "laptop2-nixos";
		volumeID = "laptop2-nixos";

		# TODO: finalize a self contained/offline installer iso
		# the 2 options might be a lead. 'includeSystemBuildDeps' bloats the
		# nix/store extremly and storeContents expects JSON as input.
		#includeSystemBuildDependencies = true;
		#storeContents = [ laptop2 ];

		contents = [
			# TODO once the shell scripts have been split up, rename target files
			{ source = sourceInfo + "/nix/installer/laptop2/format.sh";
			  target = "/install.sh";
			}
			/*{ source = sourceInfo.outPath;
			  target = "/flake-sourceInfo";
			}*/
			{ source = secrets.git-crypt.key-file;
			  target = "/git-crypt-key-file";
			}
		];
	};
}
