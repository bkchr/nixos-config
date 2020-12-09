with import <nixpkgs> {};
let
  pkgs = import <nixpkgs> {};
  myrust = ((rustChannelOf { date = "2020-10-04"; channel = "nightly"; }).rust.override { extensions = [ "rust-src" "rust-analysis" "rustfmt-preview" ]; targets = [ "wasm32-unknown-unknown" ]; });
  polkadot-launch-src = pkgs.fetchFromGitHub {
    owner = "shawntabrizi";
    repo = "polkadot-launch";
    rev = "36da43aa3fca9addfb598eb70afcd8a5e52b535b";
    sha256 = "19pv1ip5n7cw2hq9bbkhi8w2nrj0a6vi5hrm31ksfs3si7jr1dzq";
  };
  polkadot-launch = pkgs.callPackage "${polkadot-launch-src}/default.nix" {};
in
  pkgs.mkShell {
    buildInputs = [
      myrust openssl pkgconfig cmake python3 llvmPackages.clang-unwrapped gnuplot libbfd libopcodes libunwind autoconf automake libtool rsync yarn nodejs nodePackages.typescript
      polkadot-launch
    ];
    LIBCLANG_PATH="${llvmPackages.libclang}/lib";
    RUST_SRC_PATH = "${myrust}/lib/rustlib/src/rust/library";
    ROCKSDB_LIB_DIR="${rocksdb}/lib";
    PROTOC = "${protobuf}/bin/protoc";
    CARGO_INCREMENTAL = "1";
  }
