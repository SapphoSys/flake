{ lib, config, ... }:

{
  options = {
    settings.remoteBuilder.enable = lib.mkEnableOption "remote builder access for distributed builds";
  };

  config = lib.mkIf config.settings.remoteBuilder.enable {
    # Create a dedicated user for remote build access
    users.users.remotebuild = {
      isNormalUser = true;
      createHome = false;
      group = "remotebuild";
      description = "Remote build user for distributed builds";

      # The public key will need to be added here from the local machine
      # You'll need to run: ssh-keygen -f /root/.ssh/remotebuild
      # on the local machine (Steam Deck) and copy remotebuild.pub here
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMLdxEmVv6BW/TCDxlTyMqHv/TzU9E3LR9Yu5QfL3aY root@serenity"
      ];
    };

    users.groups.remotebuild = { };

    # Optimize for remote building
    nix = {
      # Increase number of build users for better parallelism
      nrBuildUsers = 64;

      settings = {
        # Trust the remotebuild user to request builds
        trusted-users = [ "remotebuild" ];

        # Automatic garbage collection to prevent disk filling
        min-free = lib.mkDefault (10 * 1024 * 1024 * 1024); # 10 GB
        max-free = lib.mkDefault (200 * 1024 * 1024 * 1024); # 200 GB

        # Maximize parallel building
        max-jobs = "auto";
        cores = 0; # Use all available cores
      };
    };

    # Limit memory usage to prevent OOM on large builds
    systemd.services.nix-daemon.serviceConfig = {
      MemoryAccounting = true;
      MemoryMax = "90%";
      OOMScoreAdjust = 500; # Kill nix builds first if OOM
    };
  };
}
