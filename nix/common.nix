{ pkgs, lib, ... }:
{
	nix = {
		# https://www.tweag.io/blog/2020-07-31-nixos-flakes/
		# "required to have nix beta flake support"
		package = pkgs.nixVersions.latest;

		settings = {
			system-features = [ "nix-command" "flakes" "big-parallel" "kvm" ];
			#auto-optimize-store = true; # optimize the store on every build, heavy IO + cpu
		};

		optimise = {
			automatic = true;
			dates = [ "weekly" ];
		};

		gc = {
			automatic = true;
			options = "--delete-old";
			dates = "weekly";
		};
	};

	# TODO: move these packages in a user context, not global installation.
	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
		mtr
	];

	system = {
		stateVersion = "24.11";
		autoUpgrade = {
			enable = true;
			allowReboot = true;
			dates = "03:00";
			flake = "github:proxemy/home";
			flags = [ "-L" "--verbose" "--show-trace" ]; # to get extended build logs
			randomizedDelaySec = "30min";
		};
	};

	hardware = {
		bluetooth.enable = false;
		pulseaudio.enable = true;
	};

	services.openssh = lib.mkForce {
		enable = true;
		settings = {
			PasswordAuthentication = false;
			KbdInteractiveAuthentication = false;
			PermitRootLogin = "no";
			UseDns = false;
			X11Forwarding = false;
		};
		extraConfig = ''
			Banner none
			LoginGraceTime 10
			ChallengeResponseAuthentication no
			KerberosAuthentication no
			GSSAPIAuthentication no
			AllowAgentForwarding no
			AllowTcpForwarding no
			PermitTunnel no
			PermitUserEnvironment no

			#UseRoaming no # <- client config
		'';
	};
}
