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

    # try out tailscale ssh
    ssh.enable = false;
    tailscale.advertiseConnector = true;
  };

  system.stateVersion = "25.05";
}
