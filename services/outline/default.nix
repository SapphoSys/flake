{ config, ... }:

{
  age.secrets = {
    outlineClientSecret = {
      file = ../../secrets/outline/client-secret.age;
      mode = "600";
      owner = "outline";
      group = "outline";
    };
    outlineB2Secret = {
      file = ../../secrets/outline/b2-application-key.age;
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
      accessKey = "0025958249af2220000000019";
      secretKeyFile = config.age.secrets.outlineB2Secret.path;
      uploadBucketName = "sapphic-outline";
      uploadBucketUrl = "https://s3.us-west-002.backblazeb2.com";
      region = "us-west-002";
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

  # Backblaze B2's S3 API supports presigned PUT uploads, which Outline can
  # use instead of the presigned POST flow
  systemd.services.outline.environment.AWS_S3_UPLOAD_METHOD = "put";

  services.caddy.virtualHosts."wiki.sappho.systems" = {
    extraConfig = ''
      import common
      import tls_bunny
      reverse_proxy http://localhost:3300
    '';
  };
}
