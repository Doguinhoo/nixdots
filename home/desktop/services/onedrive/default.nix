{config, ...}: {
  home.file.onedrive = {
    text = "sync_dir = \"/run/media/lucas/9282048d-b2a4-47b7-b0f4-14c877d494d0/OneDrive/\"";
    target = ".config/onedrive/config";
  };
}
