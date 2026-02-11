{
  # Enable Homebrew
  homebrew = {
    enable = true;

    # Update Homebrew and upgrade all packages on activation
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # Uninstall all programs not declared
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
      "bruno"
      "crossover"
      "discord"
      "figma"
      "iina"
      "maccy"
      "microsoft-edge"
      "microsoft-teams"
      "mos"
      "music-presence"
      "prismlauncher"
      "osu"
      "signal"
      "slack"
      "steam"
      "tailscale-app"
      "telegram"
      "whatsapp"
    ];
  };
}
