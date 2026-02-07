{ ... }:

{
  imports = [
    ./hardware.nix
  ];

  jovian = {
    steam.user = "chloe";
    decky-loader.user = "chloe";
  };

  settings = {
    desktop = {
      kde.enable = true;
    };

    hardware = {
      audio.enable = false;
    };

    profiles = {
      graphical.enable = true;
      steamdeck.enable = true;
    };
  };

  system.stateVersion = "25.05";
}
