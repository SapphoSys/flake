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
    # Override kernel config to disable unnecessary drivers for Steam Deck
    # This significantly reduces kernel build time by removing drivers for
    # hardware that will never be present on a Steam Deck
    boot.kernelPackages = lib.mkForce (pkgs.linuxPackages_jovian.extend (
      self: super: {
        kernel = super.kernel.override {
          structuredExtraConfig = with lib.kernel; {
            # ===== GPU Drivers =====
            # Disable NVIDIA drivers (nouveau)
            DRM_NOUVEAU = no;
            DRM_NOVA = no;

            # Disable Intel graphics drivers
            DRM_I915 = no;
            DRM_XE = no;

            # Keep AMD GPU driver enabled (Steam Deck uses AMD RDNA 2)
            DRM_AMDGPU = module;
            DRM_AMD_DC = yes;
            HSA_AMD = yes;

            # Disable other GPU vendors
            DRM_RADEON = no; # Older AMD cards
            DRM_GMA500 = no; # Intel GMA
            DRM_MGAG200 = unset; # Matrox
            DRM_AST = unset; # ASPEED
            DRM_BOCHS = unset; # QEMU
            DRM_CIRRUS_QEMU = unset;
            DRM_QXL = unset; # QEMU/Xen
            DRM_VIRTIO_GPU = unset; # Virtualization
            DRM_VMWGFX = unset; # VMware

            # ===== WiFi Drivers =====
            # Disable all WiFi vendors except what Steam Deck uses
            WLAN_VENDOR_ADMTEK = no;
            WLAN_VENDOR_ATH = no; # Atheros (big time saver!)
            WLAN_VENDOR_ATMEL = no;
            WLAN_VENDOR_BROADCOM = no;
            WLAN_VENDOR_CISCO = no;
            WLAN_VENDOR_INTEL = no;
            WLAN_VENDOR_INTERSIL = no;
            WLAN_VENDOR_MARVELL = no;
            WLAN_VENDOR_MEDIATEK = module; # Steam Deck uses MediaTek MT7921
            WLAN_VENDOR_MICROCHIP = no;
            WLAN_VENDOR_PURELIFI = no;
            WLAN_VENDOR_RALINK = no;
            WLAN_VENDOR_REALTEK = module; # Keep as backup
            WLAN_VENDOR_RSI = no;
            WLAN_VENDOR_SILABS = no;
            WLAN_VENDOR_ST = no;
            WLAN_VENDOR_TI = no;
            WLAN_VENDOR_ZYDAS = no;
            WLAN_VENDOR_QUANTENNA = no;

            # ===== Media Drivers =====
            # Steam Deck has no TV tuners, webcams, or capture cards
            MEDIA_ANALOG_TV_SUPPORT = no;
            MEDIA_DIGITAL_TV_SUPPORT = no;
            MEDIA_RADIO_SUPPORT = no;
            MEDIA_SDR_SUPPORT = no;
            MEDIA_CEC_SUPPORT = no;
            DVB_CORE = unset;

            # ===== Other Unnecessary Hardware =====
            NFC = no; # No NFC chip
            HAMRADIO = no; # No amateur radio
            STAGING = no; # Experimental/unmaintained drivers (huge!)
            RC_CORE = unset; # Infrared remote controls
            LIRC = unset; # IR transceivers

            # Old/obscure ethernet cards
            NET_VENDOR_3COM = no;
            NET_VENDOR_ADAPTEC = no;
            NET_VENDOR_ALTEON = no;
            NET_VENDOR_BROADCOM = no;
            NET_VENDOR_BROCADE = no;
            NET_VENDOR_CHELSIO = no;
            NET_VENDOR_CISCO = no;
            NET_VENDOR_DEC = no;
            NET_VENDOR_DLINK = no;
            NET_VENDOR_EMULEX = no;
            NET_VENDOR_GOOGLE = no;
            NET_VENDOR_HUAWEI = no;
            NET_VENDOR_MARVELL = no;
            NET_VENDOR_MELLANOX = no;
            NET_VENDOR_MYRI = no;
            NET_VENDOR_NETERION = no;
            NET_VENDOR_NVIDIA = no;
            NET_VENDOR_OKI = no;
            NET_VENDOR_QLOGIC = no;
            NET_VENDOR_SOLARFLARE = no;
            NET_VENDOR_SUN = no;
            NET_VENDOR_TEHUTI = no;
            NET_VENDOR_TI = no;
            NET_VENDOR_VIA = no;

            # USB Serial adapters (keep core USB support)
            USB_SERIAL_GENERIC = unset;
            USB_SERIAL_SIMPLE = unset;

            # Disable most IIO sensors (keep what Steam Deck needs)
            IIO_TRIGGERED_BUFFER = module; # Needed for Steam Deck sensors
            # But disable specific vendors we don't need

            # Industrial/embedded systems
            INFINIBAND = unset; # InfiniBand networking (servers)
            ISDN = no; # ISDN modems (obsolete)
            CAN = unset; # CAN bus (automotive/industrial)
          };
        };
      }
    ));
  };
}
