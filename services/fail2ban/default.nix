{ config, pkgs, ... }:

{
  age.secrets.abuseipdb = {
    file = ../../secrets/abuseipdb.age;
    mode = "600";
  };

  services.fail2ban = {
    enable = config.settings.ssh.enable;

    # Include curl for making HTTP requests to AbuseIPDB
    extraPackages = [ pkgs.curl ];

    # Globally applicable settings for all jails
    daemonSettings = {
      Definition = {
        # How long to keep an IP in the ban list (in seconds)
        # 1 day = 86400 seconds
        bantime = "86400";

        # How far back to look for failures (in seconds)
        # 1 hour = 3600 seconds
        findtime = "3600";

        # Number of failures before banning
        maxretry = 3;

        # Allow fail2ban to write to syslog
        logtarget = "SYSLOG";
      };
    };

    # Ignore local networks and trusted services
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "100.64.0.0/10" # Tailscale IP range
    ];

    # Jails for protecting various services
    jails = {
      # SSH protection - monitor failed login attempts using systemd journal
      sshd.settings = {
        enabled = true;
        port = "ssh";
        filter = "sshd";
        backend = "systemd";
        maxretry = 5;
        findtime = "3600";
        bantime = "86400";
        action = "iptables-multiport[name=SSH, port='ssh'] abuseipdb-agenix[abuseipdb_category='18,22']";
      };

      # Caddy HTTP/HTTPS protection - monitor for repeated 4xx/5xx errors
      caddy-http.settings = {
        enabled = true;
        port = "http,https";
        filter = "caddy-http";
        logpath = "/var/log/caddy/access-*.log";
        backend = "auto";
        maxretry = 10;
        findtime = "600";
        bantime = "3600";
        action = "iptables-multiport[name=Caddy, port='http,https'] abuseipdb-agenix[abuseipdb_category='21']";
      };

      # Rate-based protection - ban on excessive requests
      caddy-ratelimit.settings = {
        enabled = true;
        port = "http,https";
        filter = "caddy-ratelimit";
        logpath = "/var/log/caddy/access-*.log";
        backend = "auto";
        maxretry = 50;
        findtime = "60";
        bantime = "1800";
        action = "iptables-multiport[name=Caddy-RateLimit, port='http,https'] abuseipdb-agenix[abuseipdb_category='21']";
      };
    };
  };

  # Custom filters for Fail2Ban
  environment.etc = {
    # Caddy HTTP error monitoring filter
    "fail2ban/filter.d/caddy-http.conf".text = ''
      [Definition]
      failregex = ^<HOST> -.*" (?:400|401|403|404|405|429|500|502|503|504) .*$
      ignoreregex =
    '';

    # Caddy rate limiting filter - detects repeated requests within short timeframe
    "fail2ban/filter.d/caddy-ratelimit.conf".text = ''
      [Definition]
      failregex = ^<HOST> -.*" \d{3} .*$
      ignoreregex =
    '';

    # Custom abuseipdb action that reads API key from file
    "fail2ban/action.d/abuseipdb-agenix.conf".text = ''
      [Definition]
      # Report IP to AbuseIPDB, reading API key from Agenix secret file
      # Uses double quotes to allow shell expansion of $(cat /run/agenix/abuseipdb)
      # Sleep 12 seconds to respect AbuseIPDB rate limit (~5 requests per minute)
      # Note: Don't use <matches> - fail2ban's wrapper causes issues with multiline content
      # Don't use --fail so 429 rate limit errors don't mark action as failed
      actionban = sleep 12; curl 'https://api.abuseipdb.com/api/v2/report' -H 'Accept: application/json' -H "Key: $(cat /run/agenix/abuseipdb)" --data-urlencode 'ip=<ip>' --data 'categories=<abuseipdb_category>' > /dev/null 2>&1

      actionstart =
      actionstop =
      actioncheck =
      actionunban =

      [Init]
      abuseipdb_category = 18
    '';
  };

  # Ensure the log directory exists
  systemd.tmpfiles.rules = [
    "d /var/log/fail2ban 0755 root root -"
  ];
}
