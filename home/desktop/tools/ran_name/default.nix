{pkgs, ...}: {
  home.packages = [
    (pkgs.callPackage ../../../../pkgs/ran_name/default.nix {})
  ];
}
