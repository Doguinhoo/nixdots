{
  inputs,
  pkgs,
  config,
  ...
}: let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        gamescope
        mangohud
      ];
  };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  boot = {
    kernelModules = ["v4l2loopback"]; # Autostart kernel modules on boot
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback xpadneo]; # loopback module to make OBS virtual camera work
    kernelParams = [];
    supportedFilesystems = ["ntfs" "hid_xpadneo"];
    loader = {
      systemd-boot = {
        enable = false;
        # https://github.com/NixOS/nixpkgs/blob/c32c39d6f3b1fe6514598fa40ad2cf9ce22c3fb7/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix#L66
        editor = false;
      };
      timeout = 10;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 5;
        theme =
          pkgs.fetchFromGitHub
          {
            owner = "Lxtharia";
            repo = "minegrub-theme";
            rev = "193b3a7c3d432f8c6af10adfb465b781091f56b3";
            sha256 = "1bvkfmjzbk7pfisvmyw5gjmcqj9dab7gwd5nmvi8gs4vk72bl2ap";
          };
      };
    };
  };

  hardware = {
    xpadneo.enable = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      XCURSOR_SIZE = "32";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GTK_THEME = "Catppuccin-Mocha-Compact-Blue-dark";
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
      #DEFAULT_BROWSER = "${pkgs.brave}/bin/brave"; # Set default browser
    };
  };

  # Configure console keymap
  console = {keyMap = "br-abnt2";};

  networking = {
    networkmanager.enable = true;
    #enableIPv6 = false;
    # no need to wait interfaces to have an IP to continue booting
    dhcpcd.wait = "background";
    # avoid checking if IP is already taken to boot a few seconds faster
    dhcpcd.extraConfig = "noarp";
    hostName = "nixos"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  users = {
    users = {
      leonardo = {
        isNormalUser = true;
        description = "leonardo";
        initialPassword = "123456";
        shell = pkgs.zsh;
        extraGroups = ["networkmanager" "wheel" "input" "docker" "kvm" "libvirtd"];
      };
    };
  };

  # Enable and configure `doas`.
  security = {
    rtkit.enable = true;
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
    sudo = {
      enable = false;
    };
    doas = {
      enable = true;
      extraRules = [
        {
          users = ["leonardo"];
          keepEnv = true;
          persist = true;
        }
      ];
    };
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Iosevka Aile, Times, Noto Serif"];
        sansSerif = ["Iosevka Aile, Helvetica Neue LT Std, Helvetica, Noto Sans"];
        monospace = ["Courier Prime, Courier, Noto Sans Mono"];
      };
    };
  };

  programs = {
    zsh.enable = true;
    hyprland = {
      enable = true;
    };
    nix-ld = {
      enable = true;
      package = inputs.nix-ld-rs.packages.${pkgs.system}.nix-ld-rs;
    };
    noisetorch = {
      enable = true;
    };
  };

  # Enables docker in rootless mode
  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    # Enables virtualization for virt-manager
    libvirtd.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      auto-optimise-store = true;
      http-connections = 50;
      warn-dirty = false;
      log-lines = 50;
      sandbox = "relaxed";
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  programs = {
    gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
      };
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
    };
  };

  # Change systemd stop job timeout in NixOS configuration (Default = 90s)
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    services.NetworkManager-wait-online.enable = false;
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Configure keymap in X11
  sound.enable = true;
  services = {
    fstrim.enable = true;
    gvfs.enable = true;
    onedrive.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber.enable = true;
      jack.enable = false;
      pulse.enable = true;
      audio.enable = true;
      lowLatency = {
        # enable this module
        enable = true;
        # defaults (no need to be set unless modified)
      };
    };

    displayManager = {
      defaultSession = "hyprland";
      autoLogin.user = "leonardo";
    };

    sshd.enable = true;
    # Enable CUPS to print documents.
    # printing.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        sessionCommands = ''
          xset r rate 150 25
          xrandr --output DP-0 --mode 1920x1080 --rate 165 --primary
          nitrogen --restore
        '';
      };
      desktopManager = {
        xfce.enable = false;
      };
      windowManager = {
        awesome = {
          enable = false;
          luaModules = with pkgs.luaPackages; [
            luarocks
            # luadbi-mysql
          ];
        };
        #xmonad = {
        #  enable = true;
        #  enableContribAndExtras = true;
        #  enableConfiguredRecompile = false;
        #  extraPackages = hpkgs: [
        #    hpkgs.xmobar
        #  ];
        #  config = builtins.readFile ../../home/desktop/desktop/xmonad/xmonad.hs;
        #};
      };
      libinput = {
        enable = true;
        mouse = {
          accelProfile = "flat";
        };
        touchpad = {
          accelProfile = "flat";
        };
      };
      xkb = {
        variant = "thinkpad";
        layout = "br";
      };
    };
    logmein-hamachi.enable = false;
    flatpak.enable = false;
    #autorandr = {
    #  enable = true;
    #  profiles = {
    #    leonardo = {
    #      config = {
    #DP-0 = {
    #  enable = true;
    #  primary = true;
    #  mode = "1920x1080";
    #  rate = "165.00";
    #  position = "0x0";
    #};
    #     };
    #   };
    # };
    #};
  };

  services.blueman.enable = true;
  hardware.bluetooth = {
    #package = pkgs.bluez;
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    playerctl
    inputs.xdg-portal-hyprland.packages.${system}.xdg-desktop-portal-hyprland
    xorg.xhost
  ];

  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
  };

  security.polkit.enable = true;

  #steam
  programs.steam = {
    # enable steam as usual
    package = steam-with-pkgs;
    enable = true;
    # add extra compatibility tools to your STEAM_EXTRA_COMPAT_TOOLS_PATHS using the newly added `extraCompatPackages` option
    extraCompatPackages = [
      # add the packages that you would like to have in Steam's extra compatibility packages list
      pkgs.proton-ge-bin
      # etc.
    ];
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
