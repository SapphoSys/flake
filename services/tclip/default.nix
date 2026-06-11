{ config, inputs, ... }:

{
  imports = [
    inputs.tclip.nixosModules.default
  ];

  age.secrets.tclip = {
    file = ../../secrets/tclip.age;
    mode = "600";
  };

  services.tclip = {
    enable = true;
    authKeyFile = config.age.secrets.tclip.path;
    hostname = "paste";
    enableLineNumbers = true;
    enableWordWrap = true;
  };
}
