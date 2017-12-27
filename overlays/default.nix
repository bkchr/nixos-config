self: super:

with super.lib;

(foldl' (flip extends) (_: super) [

  (import ./nixpkgs-mozilla/default.nix)
  (import ./wabt-overlay/overlay/default.nix)

]) self
