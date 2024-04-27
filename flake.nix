{
  description = "A faster time library";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
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
        default = overlay;
      };
    } //
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlay];
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
