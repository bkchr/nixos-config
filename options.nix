{ lib, ... }:

{
  options.computerType = lib.mkOption {
    type = lib.types.enum [ "desktop" "laptop" ];
    description = "The type of computer we're using.";
  };
}
