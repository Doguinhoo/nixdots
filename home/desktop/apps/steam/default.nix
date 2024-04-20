{pkgs, ...}: {
  programs = {
    steam.enable = true;
    steam.remotePlay.openFirewall = true;
  };

  home.packages = [
    pkgs.steam
    (pkgs.makeDesktopItem {
      name = "Steam (Gamepad UI)";
      desktopName = "Steam (Gamepad UI)";
      genericName = "Application for managing and playing games on Steam.";
      categories = ["Network" "FileTransfer" "Game"];
      type = "Application";
      icon = "steam";
      exec = "steamos";
      terminal = false;
    })

    (pkgs.writeShellScriptBin "steamos" ''
      gamescope -F nis -h 1440 -H 2560 -b -f -e --adaptive-sync -r 165 --expose-wayland -- steam -gamepadui -steamdeck -steamos -fulldesktopres -tenfoot
    '')
  ];

  services.xserver.windowManager.session = [
    {
      name = "Console";
      start = ''
        steamos
      '';
    }
  ];
}
