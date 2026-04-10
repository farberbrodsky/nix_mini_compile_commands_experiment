{
  description = "A very basic flake";

  inputs = {
    parent.url = ./..;
    mini-compile-commands = { url = "github:danielbarter/mini_compile_commands"; flake = false; };
  };

  outputs = { parent, mini-compile-commands, ... }:
    {
      packages = parent.inputs.nixpkgs.lib.flip builtins.mapAttrs parent.inputs.nixpkgs.legacyPackages (_system: pkgs:
        let
          mcc = (pkgs.callPackage mini-compile-commands {});
        in
          {
            default = (pkgs.jq.override {
              stdenv = mcc.wrap pkgs.stdenv;
            }).overrideAttrs (finalAttrs: previousAttrs: {
              buildInputs = (previousAttrs.buildInputs or []) ++ [ mcc.hook ];
              # BUG: WHY WAS THIS NEEDED?
              nativeBuildInputs = (previousAttrs.nativeBuildInputs or []) ++ [ mcc.package ];
            });
          }
      );
    };
}
