{
  services.adguardhome = {
    enable = false;

    # We'll be using Tailscale Services to serve AdGuard Home as a subdomain in our tailnet.
    host = "127.0.0.1";
    port = 3000;

    settings = {
      # AdGuard Home keeps insisting on forcing the Russian language on me for some reason.
      language = "en";

      # Use the auto theme so it matches the user's system theme.
      theme = "auto";

      dns = {
        # Since we're not exposing AdGuard Home to the public internet, we can disable rate limiting.
        ratelimit = 0;

        bootstrap_dns = [
          "9.9.9.9" # Quad9
          "1.1.1.1" # Cloudflare
        ];

        upstream_dns = [
          "https://dns10.quad9.net/dns-query"
          "https://doh.mullvad.net/dns-query"
          "https://security.cloudflare-dns.com/dns-query"

          # Resolve DNS queries for 100.* IPs with Tailscale's Magic DNS.
          "[/100.in-addr.arpa/]100.100.100.100"
        ];

        allowed_clients = [
          "100.64.0.0/10" # Tailscale IP range
          "127.0.0.1/24" # localhost
        ];
      };

      clients.persistent = [
        {
          name = "macOS";
          ids = [ "100.118.131.42" ];
        }
        {
          name = "Android";
          ids = [ "100.113.214.72" ];
        }
        {
          name = "UpCloud";
          ids = [ "100.96.154.98" ];
        }
        {
          name = "Windows";
          ids = [ "100.124.27.32" ];
        }
        {
          name = "Windows Subsystem for Linux";
          ids = [ "100.127.166.121" ];
        }
      ];
    };
  };
}
