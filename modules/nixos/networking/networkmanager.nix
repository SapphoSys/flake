{
  # Enable systemd-resolved for proper DNS
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      FallbackDNS = [
        "8.8.8.8"
        "1.1.1.1"
      ];
    };
  };

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    unmanaged = [
      "interface-name:tailscale*"
      "interface-name:docker*"
      "type:bridge"
    ];
  };

  # On rebuilds, NetworkManager's wait online process often fails, so we disable it.
  systemd.services.NetworkManager-wait-online.enable = false;
}
