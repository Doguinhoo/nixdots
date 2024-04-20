{ pkgs, ... }: {
  home.packages = [
    (pkgs.callPackage ../../../../pkgs/catsay/default.nix { })
  ];
}