with import <nixpkgs> {};
let
  pkgs = import <nixpkgs> {};
  myrust = ((rustChannelOf { date = "2020-10-04"; channel = "nightly"; }).rust.override { extensions = [ "rust-src" "rust-analysis" "rustfmt-preview" ]; targets = [ "wasm32-unknown-unknown" ]; });
  polkadot-launch-src = pkgs.fetchFromGitHub {
    owner = "shawntabrizi";
    repo = "polkadot-launch";
    rev = "4b854e9df6a7219019fc9bf3cc1eaf75b85aa591";
    sha256 = "16qv867w32n19f3rkvrabgw107f2dn2nyj3dbbx16v31822mly7s";
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
