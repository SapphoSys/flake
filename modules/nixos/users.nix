{ pkgs, ... }:

{
  users.users = {
    chloe = {
      isNormalUser = true;

      extraGroups = [
        "networkmanager"
        "wheel"
      ];

      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJOAijXc0QNfeoCsQkaB7ybm9G+4EpFthOGy+fy+YbT"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIEXV3ACvW9TraNmdZbIh9OIEmsvcl4dLuhSmEwFkApJ"
      ];

      initialHashedPassword = "$6$ijAhPpyv5MuFlz4I$gEIK0EYwWNHG3AqOzxddvrCxwfqyQqtTdfoH5YvOTmCCljRMoBOsbNoqpSsCClipaEtIJ48BAHjzjXYdrIyF.1";
    };
    root = {
      initialHashedPassword = "$6$ijAhPpyv5MuFlz4I$gEIK0EYwWNHG3AqOzxddvrCxwfqyQqtTdfoH5YvOTmCCljRMoBOsbNoqpSsCClipaEtIJ48BAHjzjXYdrIyF.1";
    };
  };
}
