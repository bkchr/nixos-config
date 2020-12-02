{ stdenv, writeTextFile, useCargoRemote, cargo-remote }:

# Create a script that will be called by rust-analyzer to compile check the source code.
let 
  command = 
    if useCargoRemote then
      ''
        ${cargo-remote}/bin/cargo-remote remote -bSKIP_WASM_BUILD=1 check -- --message-format=json --target-dir=target/rust-analyzer
      ''
    else 
      ''
        SKIP_WASM_BUILD=1 cargo check --message-format=json --target-dir=target/rust-analyzer
      '';
in
writeTextFile {
  name = "rust-analyzer-cargo-check";

  executable = true;

  destination = "/bin/rust-analyzer-cargo-check";

  text = command;
}
