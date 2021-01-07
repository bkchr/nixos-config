{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "cargo-remote-${version}";
  version = "d16a1639d382c3bf4b3c1a7663102d0208f3b5de";
  src = fetchFromGitHub {
    owner = "bkchr";
    repo = "cargo-remote";
    rev = "${version}";
    sha256 = "05cb4w2asp7vasw1gpvwagzzafmivalbs5lqcybf238bkdaa9909";
  };

  cargoSha256 = "1ha6zzsdx3vmf9lwrijqb8lmhfpjddb1kpwdrrl84n8y753pab01";

  doCheck = false;
}
