{ config, pkgs, ... }:

{
  age.secrets.nextcloud = {
    file = ../../secrets/nextcloud.age;
    mode = "600";
  };

  services.nextcloud = {
    enable = true;
    hostName = "nc.sappho.systems";
    https = true;
    package = pkgs.nextcloud32;

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks;
      dav_push = pkgs.fetchNextcloudApp {
        appName = "dav_push";
        appVersion = "1.0.1";
        license = "AGPL-3.0-only";
        sha512 = "29b9d9a741709bad372453519be74a5661c0018c0fef135db3fef78117d8b6a2c20563b5b97bc73567f577143b695749806529fbcff4f4559ed428456c19453b";
        url = "https://github.com/bitfireAT/nc_ext_dav_push/releases/download/v1.0.1/dav_push.tar.gz";
      };
    };

    config = {
      adminpassFile = config.age.secrets.nextcloud.path;
      dbtype = "sqlite";
    };

    settings = {
      overwriteprotocol = "https";
      trusted_proxies = [ "127.0.0.1" ];
      default_phone_region = "US";
    };

    extraAppsEnable = true;
  };

  # Make nginx listen on 127.0.0.1:7070 for this vhost
  services.nginx.virtualHosts."nc.sappho.systems".listen = [
    {
      addr = "127.0.0.1";
      port = 1800;
    }
  ];

  services.caddy.virtualHosts."nc.sappho.systems" = {
    extraConfig = ''
      import common
      import tls_bunny
      reverse_proxy http://localhost:1800
    '';
  };
}
