{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    kickstart-nix-nvim.url = "github:mrcjkb/kickstart-nix.nvim";
    #nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    # from: https://www.nixhub.io/packages/python
    old-python-nixpkgs.url = "github:nixos/nixpkgs/2030abed5863fc11eccac0735f27a0828376c84e";
    plugin-onedark.url = "github:navarasu/onedark.nvim";
    plugin-onedark.flake = false;
    #devenv.url = "github:cachix/devenv";
  };

  outputs = { self , nixpkgs, home-manager, kickstart-nix-nvim,  ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    python = pkgs.python3.withPackages (ps: with ps; [ spacy ]);
  in
  {
    nixosConfigurations = {
        nixpkgs.overlays = [
        # replace <kickstart-nix-nvim> with the name you chose
        (import ./nix/neovim-overlay.nix)
    ];
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/configuration.nix

        ];
      };
    };

      devShells.x86_64-linux.default =
        pkgs.mkShell
          {
            nativeBuildInputs = with pkgs; [
              nodejs
              inputs.old-python-nixpkgs.legacyPackages.${system}.python310
              poetry
              python310Packages.pandas
              python310Packages.spacy
              python3.withPackages (pyPkgs: with pyPkgs; [ nltk spacy])
            ];
          };
  };
}
