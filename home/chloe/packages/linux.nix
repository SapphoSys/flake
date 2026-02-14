{
  pkgs,
  lib,
  osConfig,
}:

let
  packages = with pkgs; [
    # messengers
    telegram-desktop
    vesktop

    # dev tools
    httpie-desktop

    # mail
    thunderbird

    # games
    xivlauncher
    prismlauncher

    # messengers
    discord

    # other GUI apps
    obs-studio
    _1password-gui
    rustdesk
  ];
in
lib.optionals (
  osConfig.settings.profiles.graphical.enable && pkgs.stdenv.hostPlatform.isLinux
) packages
