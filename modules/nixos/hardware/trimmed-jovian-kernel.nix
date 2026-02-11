{ lib, config, ... }:

{
  options = {
    settings.hardware.trimmedJovianKernel.enable = lib.mkEnableOption "use a trimmed Jovian kernel config for faster builds";
  };

  config = lib.mkIf config.settings.hardware.trimmedJovianKernel.enable {
    # Override the Jovian kernel to use a minimal config
    nixpkgs.overlays = [
      (final: super: {
        linux_jovian = super.linux_jovian.overrideAttrs (old: {
          configfile = ./trimmed-jovian-kernel.config;
        });
      })
    ];
  };
}
