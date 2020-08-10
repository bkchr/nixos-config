with import <nixpkgs> {};
let
  pkgs = import <nixpkgs> {};
  myrust = ((rustChannelOf { date = "2020-08-04"; channel = "nightly"; }).rust.override { extensions = [ "rust-src" "rust-analysis" "rustfmt-preview" ]; targets = [ "wasm32-unknown-unknown" ]; });
in
  pkgs.mkShell {
    buildInputs = [
      myrust openssl pkgconfig cmake python3 llvmPackages.clang-unwrapped gnuplot libbfd libopcodes libunwind autoconf automake libtool rsync yarn nodejs nodePackages.typescript
    ];
    LIBCLANG_PATH="${llvmPackages.libclang}/lib";
    RUST_SRC_PATH="${myrust}/lib/rustlib/src/rust/src";
    ROCKSDB_LIB_DIR="${rocksdb}/lib";
    PROTOC = "${protobuf}/bin/protoc";
  }
