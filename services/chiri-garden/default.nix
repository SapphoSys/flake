{ pkgs, ... }:

let
  src = pkgs.fetchFromGitHub {
    owner = "SapphoSys";
    repo = "chiri.garden";
    rev = "master";
    hash = "sha256-xS9u2GPfxC+vuaQxIfg5tVoISUxOUwyY0vGF9MXtJXU=";
  };

  chiri-garden = pkgs.stdenv.mkDerivation {
    pname = "chiri-garden";
    version = "0.0.1";
    inherit src;

    pnpmDeps = pkgs.fetchPnpmDeps {
      pname = "chiri-garden";
      inherit src;
      fetcherVersion = 3;
      hash = "";
    };

    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.pnpm_9
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
