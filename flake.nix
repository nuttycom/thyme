{
  description = "A faster time library";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    true-name.url = "github:nuttycom/true-name/55b85e5d3b1e58fe97bce28e541edea4cfde9772";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    true-name,
  }: let
    pkg-name = "thyme";
    haskell-overlay = hfinal: hprev: {
      ${pkg-name} = hfinal.callCabal2nix pkg-name ./. {};
    };

    overlay = final: prev: {
      haskellPackages = prev.haskellPackages.extend haskell-overlay;
    };
  in {
      overlays = {
        default = nixpkgs.lib.composeExtensions true-name.overlays.default overlay;
      };
    } //
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [true-name.overlays.default overlay];
      };

      hspkgs = pkgs.haskellPackages;
    in {
      packages = {
        ${pkg-name} = pkgs.haskellPackages.${pkg-name};
        default = pkgs.haskellPackages.${pkg-name};
      };

      devShells = {
        default = hspkgs.shellFor {
          packages = p: [p.${pkg-name}];
          root = ./.;
          withHoogle = true;
          buildInputs = with hspkgs; [
            haskell-language-server
            cabal-install
          ];
        };
      };

      formatter = pkgs.alejandra;
    });
}
