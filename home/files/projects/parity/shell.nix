with import <nixpkgs> {};
let
  pkgs = import <nixpkgs> {};
  myrust = ((rustChannelOf { date = "2021-01-12"; channel = "nightly"; }).rust.override { extensions = [ "rust-src" "rust-analysis" "rustfmt-preview" ]; targets = [ "wasm32-unknown-unknown" ]; });
  polkadot-launch-src = pkgs.fetchFromGitHub {
    owner = "paritytech";
    repo = "polkadot-launch";
    rev = "365a21c266a20380f90df20e623c699d29879008";
    sha256 = "0451ia4a4hp1dfg5g9mbg2h7azmj9pz5qrh181srpjm8l12s4m31";
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
