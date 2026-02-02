{ config, lib, ... }:

{
  age.secrets.bluesky-pds = {
    file = ../../secrets/bluesky-pds.age;
    owner = "pds";
    group = "pds";
    mode = "600";
  };

  services.bluesky-pds = {
    enable = true;
    pdsadmin.enable = true;
    settings = {
      PDS_HOSTNAME = "pds.sappho.systems";
      PDS_PORT = 3333;
      PDS_BLOB_UPLOAD_LIMIT = "200000000"; # 200 MB
      PDS_CRAWLERS = lib.concatStringsSep "," [
        "https://bsky.network"
        "https://relay.cerulea.blue"
        "https://relay.upcloud.world"
        "https://atproto.africa"
      ];
    };
    environmentFiles = [ config.age.secrets.bluesky-pds.path ];
  };

  services.caddy.virtualHosts."pds.sappho.systems" = {
    serverAliases = [ "*.pds.sappho.systems" ];
    extraConfig = ''
      import common
      import tls_bunny

      handle / {
        respond <<EOF
      Welcome to Sapphic Angels' AT Protocol Personal Data Server (PDS).

      Website: https://sapphic.moe
          PDS: https://github.com/bluesky-social/pds
      ATProto: https://atproto.com

      🌸 🐇
      EOF 200
      }

      handle {
        reverse_proxy http://127.0.0.1:3333
      }

      handle /xrpc/app.bsky.ageassurance.getState {
        header content-type "application/json"
        header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy"
        header access-control-allow-origin "*"
        respond `{"state":{"lastInitiatedAt":"2025-07-14T14:22:43.912Z","status":"assured","access":"full"},"metadata":{"accountCreatedAt":"2022-11-17T00:35:16.391Z"}}` 200
      }
    '';
  };
}
