{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    flake-utils.url = "github:numtide/flake-utils";
    brack.url = "github:brack-lang/brack/41353171388ede015e60214fefc0b636f951f1b3";
    brack-std-html.url = "github:brack-lang/std-html";
  };

  outputs = { nixpkgs, flake-utils, brack, ... } @inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        std-html = inputs.brack-std-html.packages.${system}.default;
        brack-plugins = pkgs.stdenv.mkDerivation {
          name = "brack-plugins";
          src = pkgs.writeTextDir "dummy" "dummy";
          dontBuild = true;
          unpackPhase = "true";
          buildInputs = [
            std-html
          ];
          installPhase = ''
            mkdir -p $out/
            cp ${std-html}/*.wasm $out/
          '';
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (brack.packages.${system}.default)
            brack-plugins
          ];

          shellHook = ''
            export BRACK_PLUGINS_PATH=${brack-plugins}
          '';
        };
      }
    );
}
