{ config, ... }:

{
  age.secrets = {
    minioCredentials = {
      file = ../../secrets/minio.age;
      mode = "600";
      owner = "minio";
      group = "minio";
    };

    outlineClientSecret = {
      file = ../../secrets/outline/client-secret.age;
      mode = "600";
      owner = "outline";
      group = "outline";
    };
    outlineMinioSecret = {
      file = ../../secrets/outline/minio-password.age;
      mode = "600";
      owner = "outline";
      group = "outline";
    };
    outlineSecretKey = {
      file = ../../secrets/outline/secret-key.age;
      mode = "600";
      owner = "outline";
      group = "outline";
    };
    outlineSMTPPassword = {
      file = ../../secrets/outline/smtp-password.age;
      mode = "600";
      owner = "outline";
      group = "outline";
    };
    outlineUtilsSecret = {
      file = ../../secrets/outline/utils-secret.age;
      mode = "600";
      owner = "outline";
      group = "outline";
    };
  };

  services.outline = {
    enable = true;
    publicUrl = "https://wiki.sappho.systems";
    port = 3300;
    forceHttps = true;

    secretKeyFile = config.age.secrets.outlineSecretKey.path;
    utilsSecretFile = config.age.secrets.outlineUtilsSecret.path;

    databaseUrl = "local";
    redisUrl = "local";

    maximumImportSize = 104857600;

    storage = {
      storageType = "s3";
      accessKey = "minio";
      secretKeyFile = config.age.secrets.outlineMinioSecret.path;
      uploadBucketUrl = "https://minio.sappho.systems";
      uploadBucketName = "outline";
      region = "us-east-1";
      uploadMaxSize = 104857600;
      forcePathStyle = true;
      acl = "private";
    };

    smtp = {
      host = "smtp.purelymail.com";
      port = 587;
      username = "noreply@sapphic.moe";
      replyEmail = "noreply@sapphic.moe";
      passwordFile = config.age.secrets.outlineSMTPPassword.path;
      fromEmail = "noreply@sapphic.moe";
      secure = false;
    };

    oidcAuthentication = {
      displayName = "Pocket ID";

      clientId = "257b92c1-6b7f-41e9-a9c6-858a083295d8";
      clientSecretFile = config.age.secrets.outlineClientSecret.path;

      authUrl = "https://id.sappho.systems/authorize";
      tokenUrl = "https://id.sappho.systems/api/oidc/token";
      userinfoUrl = "https://id.sappho.systems/api/oidc/userinfo";

      usernameClaim = "preferred_username";
      scopes = [
        "openid"
        "profile"
        "email"
        "groups"
      ];
    };
  };

  services.minio = {
    enable = true;
    rootCredentialsFile = config.age.secrets.minioCredentials.path;
    dataDir = [ "/var/lib/minio" ];
    listenAddress = "0.0.0.0:9000";
    consoleAddress = "0.0.0.0:9001";
  };

  # TODO: migrate Outline storage off MinIO. Upstream has abandoned it and
  # nixpkgs marks it insecure, but keep the existing wiki storage alive until
  # the data can be moved to Garage/SeaweedFS/Ceph/etc.
  nixpkgs.config.permittedInsecurePackages = [
    "minio-2025-10-15T17-29-55Z"
  ];

  services.caddy.virtualHosts."wiki.sappho.systems" = {
    extraConfig = ''
      import common
      import tls_bunny
      reverse_proxy http://localhost:3300
    '';
  };

  services.caddy.virtualHosts."minio.sappho.systems" = {
    extraConfig = ''
      import common
      import tls_bunny
      reverse_proxy http://localhost:9000
    '';
  };
}
