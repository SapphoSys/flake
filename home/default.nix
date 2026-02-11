{ inputs, lib, ... }:

{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";

    extraSpecialArgs = { inherit inputs; };

    sharedModules = [
      {
        home.stateVersion = "23.11";

        # let HM manage itself when in standalone mode
        programs.home-manager.enable = true;
      }

      (
        { osConfig, ... }:

        # reload system units when changing configs
        {
          systemd.user.startServices = lib.mkIf (
            osConfig.services.systemd-tmpfiles.enable or false || osConfig.wsl.enable or false
          ) "sd-switch";
        }
      )
    ];

    users.chloe = ./chloe;
  };
}
