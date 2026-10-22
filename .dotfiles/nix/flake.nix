{
  description = "Packages for Linux machines that do not run NixOS";

  # The same nixpkgs as ../nixos: copy its flake.lock here when it moves (see the README)
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { nixpkgs, ... }: {
    # One entry in the user's Nix profile, which update-nix.zsh installs and upgrades.
    # Only what the distribution lacks or ships outdated; ../nixos installs the same on NixOS.
    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = import nixpkgs {
        inherit system;
        # For claude-code, as in ../nixos
        config.allowUnfree = true;
      }; in {
        dotfiles = pkgs.buildEnv {
          name = "dotfiles";
          paths = with pkgs; [
            claude-code
            gitleaks # Scans commits in the dotfiles pre-commit hook
            jq # Makes VS Code's settings in vscodium.zsh
            neovim
            # Not the FHS variant, as on NixOS: its sandbox replaces /usr, and with it
            # the distribution's git, shells and fonts
            vscodium
          ];
        };
      });
  };
}
