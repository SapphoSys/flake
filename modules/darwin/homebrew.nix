{
  # Enable Homebrew
  homebrew = {
    enable = true;

    # Update Homebrew and upgrade all packages on activation
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
      extraFlags = [
        "--zap"
        "--force-cleanup"
      ];
    };

    # Taps (third-party repositories)
    taps = [ ];

    # Formulae (CLI tools)
    brews = [
      "media-control"
      "mas"
    ];

    # Casks (GUI applications)
    casks = [
      "1password"
      "chiri"
      "crossover"
      "discord"
      "figma"
      "helium-browser"
      "iina"
      "microsoft-edge"
      "microsoft-teams"
      "mos"
      "music-presence"
      "prismlauncher"
      "raycast"
      "osu"
      "signal"
      "slack"
      "steam"
      "tailscale-app"
      "telegram"
      "thunderbird"
      "whatsapp"
    ];
  };
}
