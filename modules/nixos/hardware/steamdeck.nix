{
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.jovian.nixosModules.jovian
  ];

  config = lib.mkIf config.settings.profiles.steamdeck.enable {
    # Jovian-NixOS Steam Deck hardware support
    jovian = {
      # Enable Steam Deck hardware support
      devices.steamdeck = {
        enable = true;
        # Auto-update BIOS and controller firmware (optional)
        autoUpdate = false;
        # Enable vendor Mesa drivers for best performance
        enableVendorDrivers = true;
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

    # Additional Steam Deck-specific system configuration can go here
    # For example:
    # - Power management optimizations
    # - Network tuning for gaming
    # - Custom kernel parameters
    # - etc.
  };
}
