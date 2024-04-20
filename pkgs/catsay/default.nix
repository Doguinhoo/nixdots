{ rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "catsay";
  version = "0.1.0";

  src = ./.; # edit paths as needed
  cargoLock.lockFile = ./Cargo.lock;
}