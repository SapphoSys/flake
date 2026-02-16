{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    settings.hardware.trimmedJovianKernel.enable = lib.mkEnableOption "use a trimmed Jovian kernel config for faster builds";
  };

  config = lib.mkIf config.settings.hardware.trimmedJovianKernel.enable {
    # Use Jovian kernel but trim unnecessary drivers via kernelPatches
    # This properly merges with Jovian's existing kernel configuration
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_jovian;

    boot.kernelPatches = [
      {
        name = "trim-steam-deck-drivers";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          # ===== GPU Drivers =====
          # Disable NVIDIA drivers (nouveau) - biggest time saver
          DRM_NOUVEAU = lib.mkForce no;

          # Disable Intel graphics drivers - also big time savers
          DRM_I915 = lib.mkForce no;
          DRM_XE = lib.mkForce no;

          # ===== WiFi Drivers =====
          # Disable Atheros WiFi (Steam Deck uses MediaTek)
          WLAN_VENDOR_ATH = lib.mkForce no; # Big time saver!

          # Disable other WiFi vendors
          WLAN_VENDOR_ADMTEK = lib.mkForce no;
          WLAN_VENDOR_ATMEL = lib.mkForce no;
          WLAN_VENDOR_INTEL = lib.mkForce no;
          WLAN_VENDOR_INTERSIL = lib.mkForce no;
          WLAN_VENDOR_MARVELL = lib.mkForce no;
          WLAN_VENDOR_MICROCHIP = lib.mkForce no;
          WLAN_VENDOR_PURELIFI = lib.mkForce no;
          WLAN_VENDOR_RALINK = lib.mkForce no;
          WLAN_VENDOR_RSI = lib.mkForce no;
          WLAN_VENDOR_SILABS = lib.mkForce no;
          WLAN_VENDOR_ST = lib.mkForce no;
          WLAN_VENDOR_TI = lib.mkForce no;
          WLAN_VENDOR_ZYDAS = lib.mkForce no;
          WLAN_VENDOR_QUANTENNA = lib.mkForce no;

          # ===== Other Unnecessary Hardware =====
          NFC = lib.mkForce no; # No NFC chip
          HAMRADIO = lib.mkForce no; # No amateur radio
          STAGING = lib.mkForce no; # Experimental/unmaintained drivers (huge!)
          ISDN = lib.mkForce no; # ISDN modems (obsolete)

          # Only disable ethernet vendors without complex dependencies
          NET_VENDOR_3COM = lib.mkForce no;
          NET_VENDOR_ADAPTEC = lib.mkForce no;
          NET_VENDOR_ALTEON = lib.mkForce no;
          NET_VENDOR_DEC = lib.mkForce no;
          NET_VENDOR_DLINK = lib.mkForce no;
          NET_VENDOR_GOOGLE = lib.mkForce no;
          NET_VENDOR_HUAWEI = lib.mkForce no;
          NET_VENDOR_MYRI = lib.mkForce no;
          NET_VENDOR_NETERION = lib.mkForce no;
          NET_VENDOR_NVIDIA = lib.mkForce no;
          NET_VENDOR_OKI = lib.mkForce no;
          NET_VENDOR_SOLARFLARE = lib.mkForce no;
          NET_VENDOR_SUN = lib.mkForce no;
          NET_VENDOR_TEHUTI = lib.mkForce no;
          NET_VENDOR_VIA = lib.mkForce no;
        };
      }
    ];
  };
}
