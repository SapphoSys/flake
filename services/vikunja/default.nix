{ config, ... }:

{
  age.secrets.vikunja = {
    file = ../../secrets/vikunja.age;
    mode = "600";
    owner = "vikunja";
    group = "vikunja";
  };

  services.vikunja = {
    enable = true;

    frontendScheme = "https";
    frontendHostname = "vikunja.sappho.systems";

    address = "127.0.0.1";
    port = 3456;

    environmentFiles = [ config.age.secrets.vikunja.path ];

    database = {
      type = "sqlite";
      path = "/var/lib/vikunja/vikunja.db";
    };

    settings = {
      service = {
        publicurl = "https://vikunja.sappho.systems";
        timezone = "UTC";
        enableregistration = false;
        enabletaskattachments = true;
        enabletaskcomments = true;
        enablecaldav = true;
      };

      database = {
        type = "sqlite";
        path = "/var/lib/vikunja/vikunja.db";
      };
    };
  };

  services.caddy.virtualHosts."vikunja.sappho.systems" = {
    extraConfig = ''
      import common
      import tls_bunny
      reverse_proxy http://localhost:3456
    '';
  };
}
