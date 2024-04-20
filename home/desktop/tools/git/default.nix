_: {
  programs.git = {
    enable = true;
    userName = "lucas";
    userEmail = "patruop@gmail.com";
    extraConfig = {
      init = {defaultBranch = "main";};
      core.editor = "nvim";
      pull.rebase = false;
    };
  };
}
