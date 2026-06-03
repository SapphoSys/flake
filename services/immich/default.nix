{ config, pkgs, ... }:

let
  mediaLocation = "/mnt/immich-data";
  rcloneConfig = config.age.secrets.immich.path;
  rcloneRemote = "s3-immich:";

  waitForRcloneMount = pkgs.writeShellScript "wait-for-immich-rclone-mount" ''
    for _ in $(${pkgs.coreutils}/bin/seq 1 60); do
      if ${pkgs.util-linux}/bin/mountpoint -q ${mediaLocation}; then
        exit 0
      fi

      ${pkgs.coreutils}/bin/sleep 1
    done

    echo "timed out waiting for ${mediaLocation} to become a mountpoint"
    exit 1
  '';

  startRcloneMount = pkgs.writeShellScript "immich-rclone-mount" ''
    export PATH="/run/wrappers/bin:$PATH"

    exec ${pkgs.rclone}/bin/rclone mount ${rcloneRemote} ${mediaLocation} \
      --config ${rcloneConfig} \
      --cache-dir /var/cache/rclone-immich-data \
      --vfs-cache-mode writes \
      --dir-cache-time 72h \
      --poll-interval 15s \
      --log-level INFO
  '';
in
{
  age.secrets.immich = {
    file = ../../secrets/immich.age;
    mode = "440";
    owner = "immich";
    group = "immich";
  };

  environment.systemPackages = [
    pkgs.rclone
  ];

  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2283;
    mediaLocation = mediaLocation;

    settings = {
      server.externalDomain = "https://images.sappho.systems";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${mediaLocation} 0700 immich immich -"
  ];

  systemd.services.immich-rclone-mount = {
    description = "Mount Immich media storage from S3";
    documentation = [ "man:rclone(1)" ];

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.fuse3
      pkgs.rclone
      pkgs.util-linux
    ];

    serviceConfig = {
      Type = "simple";
      User = "immich";
      Group = "immich";
      CacheDirectory = "rclone-immich-data";
      AssertPathExists = rcloneConfig;
      ExecStart = startRcloneMount;
      ExecStartPost = waitForRcloneMount;
      ExecStop = "/run/wrappers/bin/fusermount3 -u ${mediaLocation}";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  systemd.services.immich-server = {
    bindsTo = [ "immich-rclone-mount.service" ];
    requires = [ "immich-rclone-mount.service" ];
    after = [ "immich-rclone-mount.service" ];
    serviceConfig.ExecStartPre = waitForRcloneMount;
  };

  services.caddy.virtualHosts."images.sappho.systems" = {
    extraConfig = ''
      import common
      import tls_bunny
      reverse_proxy http://127.0.0.1:2283
    '';
  };
}
