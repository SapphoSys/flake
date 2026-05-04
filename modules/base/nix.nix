# Partially taken from https://github.com/isabelroses/dotfiles/blob/main/modules/base/nix/nix.nix
{ pkgs, ... }:

{
  # Use Lix's latest package set for Nix tools.
  nixpkgs.overlays = [
    (final: prev: {
      # Custom Lix with lesbian pride 🏳️‍⚧️
      # Inspired by https://github.com/isabelroses/izlix
      lix = (prev.lixPackageSets.latest.lix).overrideAttrs (oa: {
        postPatch = oa.postPatch or "" + ''
          substituteInPlace lix/libmain/shared.cc \
            --replace-fail "(Lix, like Nix)" "(Lix, like Nix but for lesbians)"
        '';
        doInstallCheck = false;
      });

      inherit (prev.lixPackageSets.latest)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix = {
    # Use our customized Lix package.
    package = pkgs.lix;

    # Set up Nix's garbage collector to run automatically.
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    # Optimize symlinks.
    optimise.automatic = true;

    settings = {
      # Literally a CVE waiting to happen.
      accept-flake-config = false;

      # Enable Nix commands and flakes.
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Max number of parallel TCP connections for fetching imports and binary caches.
      http-connections = 50;

      # Show more log lines for failed builds.
      log-lines = 30;

      # Let the system decide the number of max jobs.
      max-jobs = "auto";

      # Free up to 20GiB whenever there's less than 5GiB left.
      min-free = 5 * 1024 * 1024 * 1024;
      max-free = 20 * 1024 * 1024 * 1024;

      # We don't want to track the registry,
      # but we do want to allow the usage of `flake:` references.
      use-registries = true;
      flake-registry = "";

      # Use XDG Base Directories for all Nix things.
      use-xdg-base-directories = true;

      # Don't warn about dirty working directories.
      warn-dirty = false;
    };
  };

  # Allow unfree packages.
  # This is sadly not enough as I still have to pass the --impure flag. Yawn.
  nixpkgs.config.allowUnfree = true;
}
