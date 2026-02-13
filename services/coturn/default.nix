{ config, ... }:

{
  # Coturn TURN/STUN server for Prosody XMPP voice/video calling
  # Enables NAT traversal for WebRTC calls through the XMPP server

  # Agenix secret for Coturn authentication
  age.secrets.coturn = {
    file = ../../secrets/coturn.age;
    mode = "640";
    owner = "turnserver";
    group = "turnserver";
  };

  services.coturn = {
    enable = true;

    # Use static auth secret (shared with Prosody)
    use-auth-secret = true;
    static-auth-secret-file = config.age.secrets.coturn.path;

    # Port range for media relay
    min-port = 49000;
    max-port = 50000;

    # Security and performance settings
    no-cli = true; # Disable telnet CLI (security)
    no-tcp-relay = true; # Use UDP only (better performance for media)

    # Realm (domain for TURN server)
    realm = "xmpp.sappho.systems";

    # Additional configuration
    extraConfig = ''
      verbose
      no-multicast-peers
      stale-nonce
    '';

    # TLS certificates (use the same ACME cert as Prosody)
    cert = "/var/lib/acme/xmpp.sappho.systems/fullchain.pem";
    pkey = "/var/lib/acme/xmpp.sappho.systems/key.pem";
  };

  # Allow turnserver user to read ACME certificates
  users.users.turnserver.extraGroups = [ "acme" ];

  # Firewall configuration
  networking.firewall = {
    # UDP port range for media relay
    allowedUDPPortRanges = [
      {
        from = config.services.coturn.min-port;
        to = config.services.coturn.max-port;
      }
    ];

    # TURN/STUN ports
    # 3478: STUN/TURN (UDP/TCP)
    # 5349: STUN/TURN over TLS
    allowedUDPPorts = [
      3478
      5349
    ];
    allowedTCPPorts = [
      3478
      5349
    ];
  };
}
