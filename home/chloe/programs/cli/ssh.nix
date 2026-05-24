{ lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."*" = lib.mkMerge [
      # {
      #   # Default configuration for all hosts
      #   AddKeysToAgent = "yes";
      #   IdentitiesOnly = true;
      # }
      (lib.mkIf pkgs.stdenv.isLinux {
        IdentityAgent = "~/.1password/agent.sock";
      })
      (lib.mkIf pkgs.stdenv.isDarwin {
        IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
      })
    ];
  };
}
