self: super:

with super.lib;

(foldl' (flip extends) (_: super) [

  (import ./nixpkgs-mozilla/default.nix)

]) self
