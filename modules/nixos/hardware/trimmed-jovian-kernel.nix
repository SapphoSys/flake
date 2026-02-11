{ lib, config, ... }:

{
  options = {
    settings.hardware.trimmedJovianKernel.enable = lib.mkEnableOption "use a trimmed Jovian kernel config for faster builds";
  };

  config = lib.mkIf config.settings.hardware.trimmedJovianKernel.enable {
    nixpkgs.overlays = [
      (final: super: {
        linux_jovian = super.linux_jovian.overrideAttrs (old: {
          # Update the config file reference
          configfile = ./trimmed-jovian-kernel.config;

          preConfigure = ''
            echo "Using trimmed Jovian kernel config"
            cp ${./trimmed-jovian-kernel.config} .config
          ''
          + (old.preConfigure or "");

          name = "linux-${old.version or "6.16.12"}-valve9-jovian1-trimmed";
        });
      })
    ];
  };
}
