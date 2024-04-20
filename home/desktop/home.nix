{inputs, ...}: {
  home = {
    username = "lucas";
    homeDirectory = "/home/lucas";
    stateVersion = "22.11";
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
  };

  # Imports
  imports = [
    ./apps
    ./cli-apps
    ./desktop
    ./hardware
    ./rice
    # ./services
    ./system
    # ./themes
    ./tools
    ./virtualization
  ];

  # Allow unfree packages + use overlays
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = with inputs; [
      # neovim-nightly-overlay.overlay
      
    ];
  };

  fonts.fontconfig.enable = true;

  # Add support for .local/bin
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["thunar.desktop"];
      "image/jpeg" = ["org.xfce.ristretto.desktop"];
      "image/jpg" = ["org.xfce.ristretto.desktop"];
      "image/png" = ["org.xfce.ristretto.desktop"];
      "text/plain" = ["org.xfce.mousepad.desktop"];
    };
  };
}
