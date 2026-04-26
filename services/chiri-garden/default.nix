{ pkgs, ... }:

let
  chiri-garden = pkgs.buildPnpmPackage {
    pname = "chiri-garden";
    version = "0.0.1";

    src = pkgs.fetchFromGitHub {
      owner = "SapphoSys";
      repo = "chiri";
      rev = "main";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    pnpmDeps = pkgs.pnpm.fetchDeps {
      pname = "chiri-garden";
      version = "0.0.1";
      src = chiri-garden.src;
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    # sharp requires libvips at build time for native bindings
    nativeBuildInputs = [ pkgs.pkg-config pkgs.vips ];
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
