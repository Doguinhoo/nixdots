{pkgs, ...}: {
  home.packages = [
    (pkgs.callPackage ../../../../pkgs/r_l/default.nix {})
  ];
}
