{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "cargo-remote-${version}";
  version = "549e2a7684f959e5c7d56583d42d7c48bda2d3ab";
  src = fetchFromGitHub {
    owner = "bkchr";
    repo = "cargo-remote";
    rev = "${version}";
    sha256 = "0661hkrxxg163vz8vd34yd35gyq1n2q89ri5pkkqyxrmbbgwra2s";
  };

  cargoSha256 = "0q6mh79a6ny75qknrh0bvxh49pi9i7sxjwqvy0vp0jadff1las4y";

  doCheck = false;
}
