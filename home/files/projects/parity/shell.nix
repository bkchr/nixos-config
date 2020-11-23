with import <nixpkgs> {};
let
  pkgs = import <nixpkgs> {};
  myrust = ((rustChannelOf { date = "2020-10-04"; channel = "nightly"; }).rust.override { extensions = [ "rust-src" "rust-analysis" "rustfmt-preview" ]; targets = [ "wasm32-unknown-unknown" ]; });
  polkadot-launch = (import (pkgs.fetchFromGitHub {
    owner = "bkchr";
    repo = "polkadot-launch";
    rev = "2c4b00c11cfa503cc5f68c4b28ed9b73eddabbc1";
    sha256 = "02h34rik5hn1gr1qm5z6xndn2jbzx307x2131r39z8sdmf5s4cp5";
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
