{
  description = "NixOS configuration for the Sapphic Angels system.";

  inputs = {
    # Packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flakes
    flake-parts.url = "github:hercules-ci/flake-parts";
    easy-hosts.url = "github:tgirlcloud/easy-hosts";

    # Systems
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Userspace
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Misc
    ## Catppuccin theme
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## nix-darwin login items
    darwin-login-items.url = "github:uncenter/nix-darwin-login-items";

    ## Nix Language Server
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Minecraft server support
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Source Dedicated Server management
    srcds-nix = {
      url = "github:ihaveamac/srcds-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Secrets management
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Logitech config tool
    solaar = {
      url = "github:Svenum/Solaar-Flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Tangled Git platform
    tangled = {
      url = "git+https://tangled.org/tangled.org/core";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Visual Studio Code Insiders
    vscode-insiders = {
      url = "github:auguwu/vscode-insiders-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.easy-hosts.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
        };

      easy-hosts = {
        path = ./hosts;

        additionalClasses = {
          wsl = "nixos";
        };

        shared = {
          modules = [ ./modules/base ];
          specialArgs = { inherit inputs; };
        };

        perClass = class: {
          modules = [ ./modules/${class}/default.nix ];
        };

        hosts = {
          aperture = {
            arch = "x86_64";
            class = "nixos";
            tags = [ "server" ];
          };

          caulfield = {
            arch = "x86_64";
            class = "nixos";
            tags = [ "laptop" ];
          };

          dullscythe = {
            arch = "x86_64";
            class = "nixos";
            tags = [ "server" ];
          };

          juniper = {
            arch = "aarch64";
            class = "darwin";
            tags = [ "laptop" ];
          };

          solstice = {
            arch = "x86_64";
            class = "wsl";
            tags = [ "wsl" ];
          };
        };
      };
    };
}
