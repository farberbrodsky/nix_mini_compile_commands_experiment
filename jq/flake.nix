{
  description = "A very basic flake";

  inputs = {
    parent.url = ./..;
    mini-compile-commands = { url = ./mini_compile_commands/default.nix; flake = false; };
  };

  outputs = { parent, mini-compile-commands, ... }:
    {
      packages = parent.inputs.nixpkgs.lib.flip builtins.mapAttrs parent.inputs.nixpkgs.legacyPackages (_system: pkgs:
        let
          mcc = (pkgs.callPackage mini-compile-commands {});
          # lib = parent.inputs.nixpkgs.lib;
        in
          {
            clang-with-indexer = pkgs.llvmPackages.clang-unwrapped.overrideAttrs (finalAttrs: previousAttrs: {
              ninjaFlags = (assert (!builtins.hasAttr "ninjaFlags" previousAttrs || previousAttrs.ninjaFlags == []); ["clangd-indexer"]);
            });
            default = (pkgs.jq.override {
              stdenv = mcc.wrap pkgs.stdenv;
            }).overrideAttrs (finalAttrs: previousAttrs: {
              buildInputs = (previousAttrs.buildInputs or []) ++ [ mcc.hook ];
            });
          }
      );
    };
}
