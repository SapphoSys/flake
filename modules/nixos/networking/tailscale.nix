# From https://github.com/isabelroses/dotfiles/blob/main/modules/nixos/networking/tailscale.nix

{ lib, config, ... }:

{
  options = {
    settings.tailscale = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Tailscale VPN client/service";
      };

      defaultFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "--ssh" ];
        description = "A list of command-line flags that will be passed to `tailscale set`";
      };

      advertiseConnector = lib.mkEnableOption "advertise this node as a Tailscale app connector";

      advertiseExitNode = lib.mkOption {
        type = lib.types.bool;
        default = config.settings.tailscale.isServer;
        description = "Whether this Tailscale instance advertises itself as an exit node";
      };

      isServer = lib.mkOption {
        type = lib.types.bool;
        default = config.settings.profiles.server.enable;
        description = "Whether this Tailscale instance is a server/relay node";
      };

      isClient = lib.mkOption {
        type = lib.types.bool;
        default = config.settings.tailscale.enable && !config.settings.tailscale.isServer;
        description = "Whether this Tailscale instance is a client";
      };
    };
  };

  config = lib.mkIf config.settings.tailscale.enable {
    settings.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

    networking.firewall = {
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      checkReversePath = false;
    };

    services.tailscale = {
      enable = true;
      permitCertUid = "root";
      useRoutingFeatures = if config.settings.tailscale.isServer then "server" else "client";
      extraSetFlags =
        config.settings.tailscale.defaultFlags
        ++ lib.optionals config.settings.tailscale.advertiseExitNode [ "--advertise-exit-node" ]
        ++ lib.optionals config.settings.tailscale.advertiseConnector [ "--advertise-connector" ];
    };

    # A server cannot be a client and vice versa
    assertions = [
      {
        assertion = config.settings.tailscale.isClient != config.settings.tailscale.isServer;
        message = "Tailscale instance cannot be both a client and a server at the same time.";
      }
      {
        assertion = !config.settings.tailscale.advertiseConnector || config.settings.tailscale.isServer;
        message = "A Tailscale app connector must be configured as a server node.";
      }
      {
        assertion = !config.settings.tailscale.advertiseExitNode || config.settings.tailscale.isServer;
        message = "A Tailscale exit node must be configured as a server node.";
      }
    ];
  };
}
