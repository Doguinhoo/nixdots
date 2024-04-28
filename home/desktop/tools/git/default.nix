_: {
  programs.git = {
    enable = true;
    userName = "Leonardo Nunes Ribeiro";
    userEmail = "leo.ribeiropoa@gmail.com";
    extraConfig = {
      init = {defaultBranch = "main";};
      core.editor = "nvim";
      pull.rebase = false;
    };
  };
}
