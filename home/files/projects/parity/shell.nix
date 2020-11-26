with import <nixpkgs> {};
let
  pkgs = import <nixpkgs> {};
  myrust = ((rustChannelOf { date = "2020-10-04"; channel = "nightly"; }).rust.override { extensions = [ "rust-src" "rust-analysis" "rustfmt-preview" ]; targets = [ "wasm32-unknown-unknown" ]; });
  polkadot-launch = (import (pkgs.fetchFromGitHub {
    owner = "bkchr";
    repo = "polkadot-launch";
    rev = "2e41f0b2cc5b8a2dc4cf8e147c5421ae030539a0";
    sha256 = "1mxy6p2l1bnshvkd2xwgf18f72xnpvjkwpzjgjqkii7x9ibyrgaw";
  }));
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
