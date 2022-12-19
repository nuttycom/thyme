{
  description = "A faster time library";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    true-name.url = "github:nuttycom/true-name/6ec32f4170a4bf823f6d80d1e3b6dc3e18746d87";
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
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [true-name.overlays.${system}.default overlay];
      };

      hspkgs = pkgs.haskellPackages;
    in {
      packages = {
        ${pkg-name} = pkgs.haskellPackages.${pkg-name};
        default = pkgs.haskellPackages.${pkg-name};
      };

      overlays = {
        default = pkgs.lib.composeExtensions true-name.overlays.${system}.default overlay;
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
