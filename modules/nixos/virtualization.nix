{
  config,
  lib,
  ...
}:

{
  options = {
    settings.virtualization.docker.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Docker virtualization support.";
    };

  };

  config = {
    virtualisation.docker.enable = config.settings.virtualization.docker.enable;

    users.users.chloe.extraGroups = lib.mkIf config.settings.virtualization.docker.enable [ "docker" ];
  };
}
