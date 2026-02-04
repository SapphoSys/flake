{ config, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/destiny-labeler/data 0755 root root -"
    "f /var/lib/destiny-labeler/data/cursor.txt 0644 root root -"
    "f /var/lib/destiny-labeler/data/labels.db 0644 root root -"
    "f /var/lib/destiny-labeler/data/labels.db-shm 0644 root root -"
    "f /var/lib/destiny-labeler/data/labels.db-wal 0644 root root -"
  ];

  age.secrets.destiny-labeler = {
    file = ../../secrets/destiny-labeler.age;
    mode = "600";
  };

  virtualisation.oci-containers.containers."destiny-labeler" = {
    image = "ghcr.io/SapphoSys/destiny-labeler:main";
    pull = "always";
    autoRemoveOnStop = false;
    ports = [ "4002:4002" ];
    environment = {
      DID = "did:plc:zt2oycjggn5gwdtcgphdh4tn";
      URL = "wss://jetstream1.us-east.bsky.network/subscribe";
      PORT = "4002";
      NODE_ENV = "production";
    };
    environmentFiles = [ config.age.secrets.destiny-labeler.path ];
    volumes = [
      "/var/lib/destiny-labeler/data/cursor.txt:/app/cursor.txt"
      "/var/lib/destiny-labeler/data/labels.db:/app/labels.db"
      "/var/lib/destiny-labeler/data/labels.db-shm:/app/labels.db-shm"
      "/var/lib/destiny-labeler/data/labels.db-wal:/app/labels.db-wal"
    ];
    extraOptions = [
      "--restart=always"
      "--network=host"
    ];
  };

  services.caddy.virtualHosts."labeler.sappho.systems" = {
    extraConfig = ''
      import common
      import tls_bunny
      reverse_proxy http://127.0.0.1:4002
    '';
  };
}
