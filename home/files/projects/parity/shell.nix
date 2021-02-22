with import <nixpkgs> {};
let
  pkgs = import <nixpkgs> {};
  myrust = ((rustChannelOf { date = "2021-02-14"; channel = "nightly"; }).rust.override { extensions = [ "rust-src" "rust-analysis" "rustfmt-preview" ]; targets = [ "wasm32-unknown-unknown" ]; });
  polkadot-launch-src = pkgs.fetchFromGitHub {
    owner = "paritytech";
    repo = "polkadot-launch";
    rev = "ca679675eccc16cab1565c478238f228922670ff";
    sha256 = "0415svji54a4s5zc0pnf9y0w3hd9hq70fsswr7w3k6zi8bjqi438";
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
