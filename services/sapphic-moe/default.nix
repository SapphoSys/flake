{
  config,
  ...
}:

{
  age.secrets = {
    sapphic-moe = {
      file = ../../secrets/sapphic-moe.age;
      mode = "600";
    };

    ghcr-io-token = {
      file = ../../secrets/ghcr-io-token.age;
      mode = "600";
    };
  };

  virtualisation.oci-containers.containers.sapphic-moe = {
    image = "ghcr.io/sapphosys/sapphic-moe:latest";
    pull = "always";

    login = {
      username = "SapphoSys";
      registry = "ghcr.io";
      passwordFile = config.age.secrets.ghcr-io-token.path;
    };

    ports = [ "4321:4321" ];

    environment = {
      NODE_ENV = "production";
      ASTRO_TELEMETRY_DISABLED = "1";
      NPM_CONFIG_UPDATE_NOTIFIER = "false";
    };

    environmentFiles = [ config.age.secrets.sapphic-moe.path ];

    autoRemoveOnStop = false;

    extraOptions = [
      "--restart=always"
      "--network=host"
    ];
  };

  services.caddy.virtualHosts."sapphic.moe" = {
    extraConfig = ''
      import common
      import tls_bunny
      reverse_proxy http://127.0.0.1:4321
    '';
  };
}
