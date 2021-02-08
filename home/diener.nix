{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "diener-${version}";
  version = "644301d71d1a31c775b8f44ecb99192ced8bc5b3";
  src = fetchFromGitHub {
    owner = "bkchr";
    repo = "diener";
    rev = "${version}";
    sha256 = "1gvrbw3x1kn28kf5xn4f81hrdcjr0z8jh19s1cv89bh0mzkycs04";
  };

  cargoSha256 = "0qv67ak056xjxlfy2hd9ivpn1ywahp0w6kwzgdngx0fhxg7jbddm";

  doCheck = false;
}
