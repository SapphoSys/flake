{ config, ... }:

{
  age.secrets.ntfy = {
    file = ../../secrets/ntfy.age;
    mode = "600";
  };

  services.ntfy-sh = {
    enable = true;

    settings = {
      base-url = "https://notify.sappho.systems";
      behind-proxy = true;
      listen-http = ":7070";

      attachment-total-size-limit = "2G";
      attachment-file-size-limit = "100M";
      attachment-expiry-duration = "20h";

      enable-login = true;
      auth-default-access = "deny-all";

      web-push-public-key = "BHJ3WXz88sWJHp-7d3O5zhkUT1yiTHQlRyWYFbmQbOJU4b5pDIhwL7hqJKXTIbCp0UFc-SfR5Rc08P8wP9abt7A";
      web-push-private-key = "${config.age.secrets.ntfy.path}";
      web-push-file = "/var/lib/ntfy-sh/webpush.db";
      web-push-email-address = "chloe@sapphic.moe";
    };
  };

  services.caddy.virtualHosts."notify.sappho.systems" = {
    extraConfig = ''
      import common
      import tls_bunny

      reverse_proxy http://127.0.0.1:7070
    '';
  };
}
