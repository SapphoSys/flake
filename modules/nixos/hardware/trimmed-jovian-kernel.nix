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
          # Disable NVIDIA drivers (nouveau)
          DRM_NOUVEAU = lib.mkForce no;
          DRM_NOVA = lib.mkForce no;

          # Disable Intel graphics drivers
          DRM_I915 = lib.mkForce no;
          DRM_XE = lib.mkForce no;

          # Disable other GPU vendors (keep AMD only)
          DRM_RADEON = lib.mkForce no; # Older AMD cards
          DRM_GMA500 = lib.mkForce no; # Intel GMA
          DRM_MGAG200 = lib.mkForce unset; # Matrox
          DRM_AST = lib.mkForce unset; # ASPEED
          DRM_BOCHS = lib.mkForce unset; # QEMU
          DRM_CIRRUS_QEMU = lib.mkForce unset;
          DRM_QXL = lib.mkForce unset; # QEMU/Xen
          DRM_VIRTIO_GPU = lib.mkForce unset; # Virtualization
          DRM_VMWGFX = lib.mkForce unset; # VMware

          # ===== WiFi Drivers =====
          # Disable all WiFi vendors except what Steam Deck uses
          WLAN_VENDOR_ADMTEK = lib.mkForce no;
          WLAN_VENDOR_ATH = lib.mkForce no; # Atheros (big time saver!)
          WLAN_VENDOR_ATMEL = lib.mkForce no;
          WLAN_VENDOR_BROADCOM = lib.mkForce no;
          WLAN_VENDOR_CISCO = lib.mkForce no;
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

          # ===== Media Drivers =====
          # Steam Deck has no TV tuners, webcams, or capture cards
          MEDIA_ANALOG_TV_SUPPORT = lib.mkForce no;
          MEDIA_DIGITAL_TV_SUPPORT = lib.mkForce no;
          MEDIA_RADIO_SUPPORT = lib.mkForce no;
          MEDIA_SDR_SUPPORT = lib.mkForce no;
          MEDIA_CEC_SUPPORT = lib.mkForce no;
          DVB_CORE = lib.mkForce unset;

          # ===== Other Unnecessary Hardware =====
          NFC = lib.mkForce no; # No NFC chip
          HAMRADIO = lib.mkForce no; # No amateur radio
          STAGING = lib.mkForce no; # Experimental/unmaintained drivers (huge!)
          RC_CORE = lib.mkForce unset; # Infrared remote controls
          LIRC = lib.mkForce unset; # IR transceivers

          # Old/obscure ethernet cards
          NET_VENDOR_3COM = lib.mkForce no;
          NET_VENDOR_ADAPTEC = lib.mkForce no;
          NET_VENDOR_ALTEON = lib.mkForce no;
          NET_VENDOR_BROADCOM = lib.mkForce no;
          NET_VENDOR_BROCADE = lib.mkForce no;
          NET_VENDOR_CHELSIO = lib.mkForce no;
          NET_VENDOR_CISCO = lib.mkForce no;
          NET_VENDOR_DEC = lib.mkForce no;
          NET_VENDOR_DLINK = lib.mkForce no;
          NET_VENDOR_EMULEX = lib.mkForce no;
          NET_VENDOR_GOOGLE = lib.mkForce no;
          NET_VENDOR_HUAWEI = lib.mkForce no;
          NET_VENDOR_MARVELL = lib.mkForce no;
          NET_VENDOR_MELLANOX = lib.mkForce no;
          NET_VENDOR_MYRI = lib.mkForce no;
          NET_VENDOR_NETERION = lib.mkForce no;
          NET_VENDOR_NVIDIA = lib.mkForce no;
          NET_VENDOR_OKI = lib.mkForce no;
          NET_VENDOR_QLOGIC = lib.mkForce no;
          NET_VENDOR_SOLARFLARE = lib.mkForce no;
          NET_VENDOR_SUN = lib.mkForce no;
          NET_VENDOR_TEHUTI = lib.mkForce no;
          NET_VENDOR_TI = lib.mkForce no;
          NET_VENDOR_VIA = lib.mkForce no;

          # USB Serial adapters (keep core USB support)
          USB_SERIAL_GENERIC = lib.mkForce unset;
          USB_SERIAL_SIMPLE = lib.mkForce unset;

          # Industrial/embedded systems
          INFINIBAND = lib.mkForce unset; # InfiniBand networking (servers)
          ISDN = lib.mkForce no; # ISDN modems (obsolete)
          CAN = lib.mkForce unset; # CAN bus (automotive/industrial)
        };
      }
    ];
  };
}
