{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.jovian.nixosModules.jovian
  ];

  config = lib.mkIf config.settings.profiles.steamdeck.enable {
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_jovian;

    # Jovian-NixOS Steam Deck hardware support
    jovian = {
      # Enable Steam Deck hardware support
      devices.steamdeck = {
        enable = true;
        # Auto-update BIOS and controller firmware (optional)
        autoUpdate = false;
        # Enable vendor Mesa drivers for best performance
        enableVendorDrivers = true;
        # Explicitly enable Steam Deck audio support
        enableSoundSupport = true;
      };

      # Enable and configure Steam Deck UI (Gaming Mode)
      steam = {
        enable = true;
        # Auto-start Gaming Mode on boot
        autoStart = true;
        # Desktop session to switch to from Gaming Mode
        desktopSession = "plasma";
        # Optional: customize environment variables
        environment = { };
      };

      # Enable Decky Loader (plugin system for Steam Deck)
      decky-loader.enable = true;
    };

    # Ensure no conflicting audio configuration
    services.pulseaudio.enable = lib.mkForce false;

    # Disable WiFi power management to try to fix issues with 5GHz networks.
    networking.networkmanager.wifi.powersave = false;
    
    # Disable WiFi power management at the driver level (wpa_supplicant/iwlwifi)
    boot.extraModprobeConfig = ''
      options iwlwifi power_save=0
      options iwlmvm power_scheme=1
    '';

    # Required for Decky Loader.
    systemd.user.tmpfiles.rules = lib.mkIf config.jovian.decky-loader.enable [
      "f /home/${config.jovian.steam.user}/.local/share/Steam/.cef-enable-remote-debugging 0644 ${config.jovian.steam.user} users -"
    ];

    # Additional Steam Deck-specific system configuration can go here
    # For example:
    # - Power management optimizations
    # - Network tuning for gaming
    # - Custom kernel parameters
    # - etc.
  };
}
