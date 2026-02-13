{ config, pkgs, ... }:

{
  disabledModules = [ "services/networking/prosody.nix" ];
  imports = [ ./module.nix ];

  # ACME certificate for XMPP domains
  # Prosody needs its own certificates for direct XMPP connections (c2s/s2s)
  # Caddy can only proxy HTTP traffic (BOSH/WebSocket)
  security.acme = {
    acceptTerms = true;
    defaults.email = "chloe@sapphic.moe";

    certs."xmpp.sappho.systems" = {
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
  };

  services.prosody = {
    enable = true;

    # file share shenanigans ig?
    xmppComplianceSuite = false;

    # Package with community modules for better compliance
    package = pkgs.prosody.override {
      withCommunityModules = [
        "smacks"
        "cloud_notify"
        "http_altconnect" # XEP-0156: Auto-creates .well-known/host-meta
        "pubsub_serverinfo" # XEP-0485: PubSub Server Information
      ];
    };

    # Automatically open firewall ports
    openFirewall = true;

    # Global settings
    settings = {
      # Admin accounts
      admins = [ "accounts+xmppadmin@xmpp.sappho.systems" ];

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
      https_ports = [ 5281 ]; # Needed for host-meta on HTTPS

      # Enable CORS for BOSH and WebSocket (XEP-0156)
      cross_domain_bosh = true;
      cross_domain_websocket = true;

      # Enable Direct TLS (XEP-0368) on alternate ports
      # Provides encrypted connections without STARTTLS
      legacy_ssl_ports = [ 5223 ]; # Required for XEP-0368 compliance
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
        "csi_simple" # Mobile battery optimization
        "cloud_notify" # Push notifications
        "pep" # Personal Eventing Protocol
        "private" # Private XML storage
        "blocklist" # User blocking
        "vcard_legacy" # vCard support
        "bookmarks" # Room bookmarks
        "server_contact_info" # XEP-0157: Contact addresses

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

      # Certificate directory (prevents errors about /etc/prosody/certs)
      certificates = "/var/lib/acme";

      # Contact information (XEP-0157)
      contact_info = {
        abuse = [
          "mailto:contact@sapphic.moe"
          "xmpp:contact@xmpp.sappho.systems"
        ];
        admin = [
          "mailto:contact@sapphic.moe"
          "xmpp:chloe@xmpp.sappho.systems"
        ];
        support = [
          "mailto:contact@sapphic.moe"
          "xmpp:chloe@xmpp.sappho.systems"
        ];
      };

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
      module = "http_file_share";
      settings = {
        http_file_share_size_limit = 100 * 1024 * 1024; # 100 MB
        http_file_share_daily_quota = 1024 * 1024 * 1024; # 1 GB per user/day
        http_file_share_global_quota = 1024 * 1024 * 2048; # 2 GB total
        http_file_share_access = [ "xmpp.sappho.systems" ]; # Domains that can use upload
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

      # XEP-0156: Alternative connection methods discovery (with CORS)
      handle /.well-known/host-meta {
        reverse_proxy https://127.0.0.1:5281
        header {
          Content-Type "application/xrd+xml"
          Access-Control-Allow-Origin "*"
        }
      }

      handle /.well-known/host-meta.json {
        reverse_proxy https://127.0.0.1:5281
        header {
          Content-Type "application/jrd+json"
          Access-Control-Allow-Origin "*"
        }
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
  # Port 5223: c2s Direct TLS (XEP-0368)
  # Port 5270: s2s Direct TLS
  # Port 5000: proxy65 (SOCKS5 file transfer proxy)
  # Port 5281: HTTPS for host-meta (XEP-0156)
  settings.firewall.allowedTCPPorts = [
    5000
    5223
    5270
    5281
  ];

  # Allow Caddy to read the ACME certificate (both services need access)
  users.users.caddy.extraGroups = [ "prosody" ];
}
