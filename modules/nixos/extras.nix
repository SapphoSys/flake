{ inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
    (import inputs.vscode-insiders)
  ];

  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.ragenix.nixosModules.default
    inputs.srcds-nix.nixosModules.default
    inputs.tangled.nixosModules.knot
    inputs.tranquil.nixosModules.default
  ];
}
