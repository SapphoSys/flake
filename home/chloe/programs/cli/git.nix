{
  pkgs,
  ...
}:

let
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM6XP+CNc2CStEDe/W4LfkcRcG98obQiM2aqnydCRbX";

  opSshSignPath =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "${pkgs._1password-gui}/bin/op-ssh-sign";
in
{
  home.file.".ssh/allowed_signers".text = "* ${signingKey}";

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Chloe A";
        email = "chloe@sapphic.moe";
        signingkey = signingKey;
      };

      gpg = {
        format = "ssh";
        ssh.program = opSshSignPath;
        ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };

      commit.gpgsign = true;
    };
  };
}
