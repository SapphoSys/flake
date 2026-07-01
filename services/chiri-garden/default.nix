{ inputs, pkgs, ... }:

let
  src = inputs."chiri-garden";
  pnpm = pkgs.pnpm;

  chiri-garden = pkgs.stdenv.mkDerivation {
    pname = "chiri-garden";
    version = "0.0.1";
    inherit src;

    pnpmDeps = pkgs.fetchPnpmDeps {
      pname = "chiri-garden";
      inherit pnpm;
      inherit src;
      fetcherVersion = 3;
      hash = "sha256-KVXHUwcN8HQK0cpG2XUz8Ktgf/t2gmR1pVBGd7Fls+4=";
    };

    nativeBuildInputs = [
      pkgs.nodejs
      pnpm
      pkgs.pnpmConfigHook
      pkgs.pkg-config
      pkgs.vips
    ];
    buildInputs = [ pkgs.vips ];

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in
{
  services.caddy.virtualHosts."chiri.garden" = {
    extraConfig = ''
      import common
      import tls_bunny
      root * ${chiri-garden}
      file_server
    '';
  };
}
