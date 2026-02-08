{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    settings.distributedBuilds = {
      enable = lib.mkEnableOption "distributed builds to remote builders";

      builders = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              hostName = lib.mkOption {
                type = lib.types.str;
                description = "Hostname or IP address of the build machine";
              };

              sshUser = lib.mkOption {
                type = lib.types.str;
                default = "remotebuild";
                description = "SSH user for connecting to the build machine";
              };

              sshKey = lib.mkOption {
                type = lib.types.str;
                default = "/root/.ssh/remotebuild";
                description = "Path to SSH private key for authentication";
              };

              systems = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ pkgs.stdenv.hostPlatform.system ];
                description = "List of system architectures the builder supports";
              };

              maxJobs = lib.mkOption {
                type = lib.types.int;
                default = 8;
                description = "Maximum number of parallel jobs";
              };

              speedFactor = lib.mkOption {
                type = lib.types.int;
                default = 2;
                description = "Speed factor relative to local builds (higher = faster)";
              };

              supportedFeatures = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                  "nixos-test"
                  "big-parallel"
                  "kvm"
                ];
                description = "List of features the builder supports";
              };

              publicHostKey = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Public host key for SSH host verification (recommended for security)";
              };
            };
          }
        );
        default = [ ];
        description = "List of remote build machines";
      };
    };
  };

  config = lib.mkIf config.settings.distributedBuilds.enable {
    # Enable distributed builds
    nix.distributedBuilds = true;

    # Configure build machines
    nix.buildMachines = map (
      builder:
      {
        hostName = builder.hostName;
        sshUser = builder.sshUser;
        sshKey = builder.sshKey;
        systems = builder.systems;
        maxJobs = builder.maxJobs;
        speedFactor = builder.speedFactor;
        supportedFeatures = builder.supportedFeatures;
      }
      // lib.optionalAttrs (builder.publicHostKey != null) {
        publicHostKey = builder.publicHostKey;
      }
    ) config.settings.distributedBuilds.builders;

    nix.settings = {
      # Allow remote builders to use substitutes (binary caches)
      # This prevents unnecessary rebuilds on the remote machine
      builders-use-substitutes = true;
    };

    # Extra Nix daemon options
    nix.extraOptions = ''
      # Maximum number of seconds to wait for a builder to respond
      connect-timeout = 5
    '';

    # SSH configuration for reliable connections
    programs.ssh.extraConfig = ''
      # Keep connections alive to remote builders
      Host *
        ServerAliveInterval 60
        ServerAliveCountMax 3
        # Accept new host keys automatically (consider setting publicHostKey instead)
        StrictHostKeyChecking accept-new
    '';
  };
}
