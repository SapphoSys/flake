{
  nix.settings = {
    substituters = [
      # Binary cache for custom Steam Deck kernel builds
      "https://sapphic-jovian.cachix.org"
    ];

    trusted-public-keys = [
      "sapphic-jovian.cachix.org-1:cpsH6OG1L5H3nFY4GW8fCfAevGd+FkqgW1vUcnD4EGg="
    ];
  };
}
