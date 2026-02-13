{ config, pkgs, ... }:

{
  disabledModules = [ "services/networking/prosody.nix" ];
  imports = [ ./module.nix ];

  # ACME certificate for XMPP domains
  # Prosody needs its own certificates for direct XMPP connections (c2s/s2s)
  # Caddy can only proxy HTTP traffic (BOSH/WebSocket)
  security.acme.certs."xmpp.sappho.systems" = {
    domain = "xmpp.sappho.systems";
    extraDomainNames = [
      "conference.xmpp.sappho.systems"
      "upload.xmpp.sappho.systems"
    ];
    dnsProvider = "bunny";
    dnsResolver = "9.9.9.9:53";
    environmentFile = config.age.secrets.caddy.path; # Reuse Caddy's Bunny API key
    group = "prosody";
  };

  services.prosody = {
    enable = true;

    # Package with community modules for better compliance
    package = pkgs.prosody.override {
      withCommunityModules = [
        "smacks"
        "cloud_notify"
      ];
    };

    # Enable XEP-0423 compliance suite
    xmppComplianceSuite = true;

    # Automatically open firewall ports
    openFirewall = true;

    # Global settings
    settings = {
      # Admin accounts
      admins = [ "accounts+xmppadmin@sapphic.moe" ];

      # Authentication
      authentication = "internal_hashed";
      allow_registration = false; # Set to true for open registration

      # Encryption requirements
      c2s_require_encryption = true;
      s2s_require_encryption = true;
      s2s_secure_auth = true;

      # HTTP configuration - Prosody listens locally, Caddy proxies
      http_interfaces = [
        "127.0.0.1"
        "::1"
      ];
      http_ports = [ 5280 ];
      https_interfaces = [ ];
      https_ports = [ ];

      # Enable Direct TLS (XEP-0368) on alternate ports
      # Provides encrypted connections without STARTTLS
      c2s_direct_tls_ports = [ 5223 ];
      s2s_direct_tls_ports = [ 5270 ];

      # Module configuration
      modules_enabled = [
        # Core XMPP features
        "roster"
        "saslauth"
        "tls"
        "dialback"
        "disco"

        # Modern XMPP (XEP-0423 compliance)
        "carbons" # Multi-device sync
        "csi" # Client State Indication
        "cloud_notify" # Push notifications
        "pep" # Personal Eventing Protocol
        "private" # Private XML storage
        "blocklist" # User blocking
        "vcard_legacy" # vCard support
        "bookmarks" # Room bookmarks

        # Message features
        "mam" # Message Archive Management
        "smacks" # Stream Management
        "ping" # Keepalive

        # User management
        "register" # In-band registration
        "time" # Entity Time
        "uptime" # Server uptime
        "version" # Software version

        # HTTP features
        "bosh" # BOSH (Jabber over HTTP)
        "websocket" # WebSocket support

        # File transfer
        "proxy65" # SOCKS5 file transfer proxy

        # Admin
        "admin_adhoc" # Admin commands via XMPP
      ];

      # Disable prosodyctl startup warnings (systemd manages the service)
      prosodyctl_service_warnings = false;

      # Limits for small server
      limits = {
        c2s = {
          rate = "10kb/s";
        };
        s2sin = {
          rate = "30kb/s";
        };
      };
    };

    # Virtual host configuration
    virtualHosts."xmpp.sappho.systems" = {
      useACMEHost = "xmpp.sappho.systems";
      settings = {
        enabled = true;
      };
    };

    # Components: Multi-User Chat (group chats)
    components."conference.xmpp.sappho.systems" = {
      module = "muc";
      settings = {
        modules_enabled = [
          "muc_mam" # Message Archive Management for MUC
          "vcard_muc" # vCard support for MUC
        ];
        name = "Sappho.Systems Chatrooms";
        restrict_room_creation = "local"; # Only local users can create rooms
        max_history_messages = 50;
        muc_room_locking = true;
        muc_room_lock_timeout = 600;
        muc_tombstones = true;
        muc_tombstone_expiry = 2592000; # 30 days
        muc_room_default_public = true;
        muc_room_default_members_only = false;
        muc_room_default_moderated = false;
        muc_room_default_public_jids = false;
        muc_room_default_change_subject = false;
        muc_room_default_history_length = 20;
        muc_room_default_language = "en";
      };
    };

    # Components: HTTP File Upload (XEP-0363)
    components."upload.xmpp.sappho.systems" = {
      module = "http_upload";
      settings = {
        http_upload_path = "${config.services.prosody.dataDir}/upload";
        http_upload_file_size_limit = 52428800; # 50 MB
        http_upload_expire_after = 2419200; # 4 weeks in seconds
        http_upload_quota = 524288000; # 500 MB per user daily quota
      };
    };
  };

  # Caddy reverse proxy configuration for HTTP endpoints (BOSH/WebSocket)
  # Uses the same ACME cert that Prosody uses (no duplicate cert acquisition)
  services.caddy.virtualHosts."xmpp.sappho.systems" = {
    useACMEHost = "xmpp.sappho.systems";
    extraConfig = ''
      import common

      # BOSH endpoint (Jabber over HTTP)
      handle /http-bind {
        reverse_proxy http://127.0.0.1:5280
      }

      # WebSocket endpoint
      handle /xmpp-websocket {
        reverse_proxy http://127.0.0.1:5280
      }

      # Respond to other requests
      respond 404
    '';
  };

  services.caddy.virtualHosts."upload.xmpp.sappho.systems" = {
    useACMEHost = "xmpp.sappho.systems"; # Cert includes this domain as SAN
    extraConfig = ''
      import common

      # HTTP file upload endpoint
      reverse_proxy http://127.0.0.1:5280
    '';
  };

  # Additional firewall ports (openFirewall handles c2s/s2s automatically)
  # Direct TLS ports (5223, 5270) are opened automatically by the module
  settings.firewall.allowedTCPPortRanges = [
    {
      from = 5000;
      to = 5100;
    } # SOCKS5 proxy port range (proxy65)
  ];
}
