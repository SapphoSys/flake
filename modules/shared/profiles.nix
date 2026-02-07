{ lib, ... }:

{
  options.settings = {
    desktop = {
      kde.enable = lib.mkEnableOption "Enable the KDE Plasma desktop environment";
    };

    profiles = {
      graphical.enable = lib.mkEnableOption "Graphical interface";
      headless.enable = lib.mkEnableOption "Headless configuration";
      laptop.enable = lib.mkEnableOption "Laptop configuration";
      server.enable = lib.mkEnableOption "Server configuration";
      steamdeck.enable = lib.mkEnableOption "Steam Deck configuration";
    };
  };
}
