{ stdenv, writeTextFile, direnv, rust-analyzer-unwrapped, bash }:

# Create a wrapped rust analyzer that is started inside a direnv provided env.
writeTextFile {
  name = "rust-analyzer-wrapped";

  executable = true;

  destination = "/bin/rust-analyzer-wrapped";

  text = ''
    #!${bash}/bin/bash
    ${direnv}/bin/direnv exec $(pwd) ${rust-analyzer-unwrapped}/bin/rust-analyzer "$@"
  '';
}
