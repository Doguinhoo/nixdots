{ rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "ran_name";
  version = "0.1.0";

  src = ./.; # edit paths as needed
  cargoLock.lockFile = ./Cargo.lock;
}