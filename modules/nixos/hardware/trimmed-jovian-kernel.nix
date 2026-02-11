{ lib, config, ... }:

{
  options = {
    settings.hardware.trimmedJovianKernel.enable = lib.mkEnableOption "use a trimmed Jovian kernel config for faster builds";
  };

  config = lib.mkIf config.settings.hardware.trimmedJovianKernel.enable {
    nixpkgs.overlays = [
      (final: super: {
        linux_jovian = super.linux_jovian.overrideAttrs (_: {
          configfile = ./trimmed-jovian-kernel.config;
        });
      })
    ];
  };
}
