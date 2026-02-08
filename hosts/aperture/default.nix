{
  imports = [
    ./hardware.nix
    ../../services
  ];

  settings = {
    bootloader.grub = {
      enable = true;
      device = "/dev/sda";
    };

    profiles = {
      headless.enable = true;
      server.enable = true;
    };

    # Enable remote builder support
    remoteBuilder.enable = true;
  };

  system.stateVersion = "25.05";
}
