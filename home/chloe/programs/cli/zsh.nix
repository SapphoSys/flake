{
  lib,
  pkgs,
  config,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    # zsh configuration file using XDG config directory
    dotDir = "${config.xdg.configHome}/zsh";

    initContent = ''
      # Add Homebrew to PATH on macOS
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      ''}
    '';

    shellAliases = {
      cat = "bat";
      cd = "z";
      ls = "eza";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "1password"
        "colored-man-pages"
        "docker"
        "docker-compose"
        "git"
        "vscode"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k-config";
        src = ../../files;
        file = "p10k.zsh";
      }
      {
        name = "zsh-powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        file = "powerlevel10k.zsh-theme";
      }
    ];
  };
}
