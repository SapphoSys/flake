{ config, ... }:

{
  age.secrets.tranquil-pds = {
    file = ../../secrets/tranquil-pds.age;
    mode = "600";
  };

  services.tranquil-pds = {
    enable = true;
    database.createLocally = true;

    settings = {
      server = {
        port = 3335;
        hostname = "velvet.sappho.systems";
        age_assurance_override = true;
      };

      firehose.crawlers = [
        "https://bsky.network"
        "https://relay.fire.hose.cam"
        "https://relay2.fire.hose.cam"
        "https://relay3.fr.hose.cam"
        "https://relay.xero.systems"
        "https://atproto.africa"
        "https://relay.whey.party"
      ];
    };

    environmentFiles = [ config.age.secrets.tranquil-pds.path ];
  };

  services.caddy.virtualHosts."velvet.sappho.systems" = {
    serverAliases = [ "*.velvet.sappho.systems" ];

    extraConfig = ''
      import common
      import tls_bunny

      reverse_proxy http://127.0.0.1:3335

      handle /xrpc/app.bsky.ageassurance.getState {
        header content-type "application/json"
        header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy"
        header access-control-allow-origin "*"
        respond `{"state":{"lastInitiatedAt":"2025-07-14T14:22:43.912Z","status":"assured","access":"full"},"metadata":{"accountCreatedAt":"2022-11-17T00:35:16.391Z"}}` 200
      }
    '';
  };
}
