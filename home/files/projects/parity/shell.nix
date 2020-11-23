with import <nixpkgs> {};
let
  pkgs = import <nixpkgs> {};
  myrust = ((rustChannelOf { date = "2020-10-04"; channel = "nightly"; }).rust.override { extensions = [ "rust-src" "rust-analysis" "rustfmt-preview" ]; targets = [ "wasm32-unknown-unknown" ]; });
  polkadot-launch = (import (pkgs.fetchFromGitHub {
    owner = "bkchr";
    repo = "polkadot-launch";
    rev = "074aaa5798c76e9309cfda8ee77d3fb3207560b9";
    sha256 = "1zlv2aanysqd7bkyw4fq3a831sm95kbv2hnnbvrysn878n9fxzbq";
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
  }
