{
  pkgs,
  lib,
  osConfig,
}:

let
  packages = with pkgs; [
    # fonts
    iosevka
    inter
    atkinson-hyperlegible
    nerd-fonts.jetbrains-mono

    # notes
    obsidian
  ];
in
lib.optionals osConfig.settings.profiles.graphical.enable packages
