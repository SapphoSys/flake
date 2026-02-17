{ ... }:

{
  imports = [
    ./hardware.nix
  ];

  jovian = {
    steam.user = "chloe";
    decky-loader.user = "chloe";
  };

  settings = {
    desktop = {
      kde.enable = true;
    };

    hardware = {
      audio.enable = false;
      trimmedJovianKernel.enable = true;
    };

    profiles = {
      graphical.enable = true;
      steamdeck.enable = true;
    };

    # Offload builds to the VPS
    distributedBuilds = {
      enable = true;
      builders = [
        {
          hostName = "aperture"; # or use IP address if hostname doesn't resolve
          sshUser = "remotebuild";
          sshKey = "/root/.ssh/remotebuild";
          systems = [ "x86_64-linux" ];
          maxJobs = 8;
          speedFactor = 4; # VPS is significantly faster than Steam Deck
          supportedFeatures = [
            "nixos-test"
            "big-parallel"
            "kvm"
          ];
        }
      ];
    };
  };

  system.stateVersion = "25.05";
}
