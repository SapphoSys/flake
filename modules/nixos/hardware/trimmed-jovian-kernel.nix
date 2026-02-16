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
          DRM_NOUVEAU_GSP_DEFAULT = lib.mkForce unset;
          DRM_NOUVEAU_SVM = lib.mkForce unset;

          # Disable Intel graphics drivers - also big time savers
          DRM_I915 = lib.mkForce no;
          DRM_I915_GVT = lib.mkForce unset;
          DRM_I915_GVT_KVMGT = lib.mkForce unset;
          DRM_XE = lib.mkForce no;

          # ===== WiFi Drivers =====
          # Disable Atheros WiFi (Steam Deck uses MediaTek)
          WLAN_VENDOR_ATH = lib.mkForce no; # Big time saver!
          ATH11K_TRACING = lib.mkForce unset;
          ATH_REG_DYNAMIC_USER_REG_HINTS = lib.mkForce unset;

          # Disable other WiFi vendors
          WLAN_VENDOR_ADMTEK = lib.mkForce no;
          WLAN_VENDOR_ATMEL = lib.mkForce no;
          WLAN_VENDOR_INTEL = lib.mkForce no;
          WLAN_VENDOR_INTERSIL = lib.mkForce no;
          WLAN_VENDOR_MARVELL = lib.mkForce no;
          WLAN_VENDOR_MICROCHIP = lib.mkForce no;
          WLAN_VENDOR_PURELIFI = lib.mkForce no;
          WLAN_VENDOR_RALINK = lib.mkForce no;
          RT2800USB_RT53XX = lib.mkForce unset;
          RT2800USB_RT55XX = lib.mkForce unset;
          WLAN_VENDOR_RSI = lib.mkForce no;
          WLAN_VENDOR_SILABS = lib.mkForce no;
          WLAN_VENDOR_ST = lib.mkForce no;
          WLAN_VENDOR_TI = lib.mkForce no;
          WLAN_VENDOR_ZYDAS = lib.mkForce no;
          WLAN_VENDOR_QUANTENNA = lib.mkForce no;

          # ===== Other Unnecessary Hardware =====
          NFC = lib.mkForce no; # No NFC chip
          HAMRADIO = lib.mkForce no; # No amateur radio
          AX25 = lib.mkForce unset; # Amateur radio protocol
          STAGING = lib.mkForce no; # Experimental/unmaintained drivers (huge!)
          STAGING_MEDIA = lib.mkForce unset;
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
