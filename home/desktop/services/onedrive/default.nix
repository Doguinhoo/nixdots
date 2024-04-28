{config, ...}: {
  home.file.onedrive = {
    text = "sync_dir = \"~/OneDrive/\"";
    target = ".config/onedrive/config";
  };
}
