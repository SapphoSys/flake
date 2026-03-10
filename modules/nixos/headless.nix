{ lib, config, ... }:

{
  config = lib.mkIf config.settings.profiles.headless.enable {
    # We print the URLs instead for servers.
    environment.variables.BROWSER = "echo";

    # We don't need fonts on a server.
    fonts = lib.mapAttrs (_: lib.mkForce) {
      packages = [ ];
      fontDir.enable = false;
      fontconfig.enable = false;
    };

    xdg = lib.mapAttrs (_: lib.mkForce) {
      autostart.enable = false;
      icons.enable = false;
      mime.enable = false;
      menus.enable = false;
      sounds.enable = false;
    };

    # Disable suspend and hibernation on headless systems
    systemd.sleep.settings.Sleep = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };
}
