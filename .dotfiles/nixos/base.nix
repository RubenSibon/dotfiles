# Every machine, including servers without a desktop.
{ pkgs, ... }:

let
  # RTK shortens command output for coding agents (see the README). nixpkgs has
  # it from 26.05 on, not in 25.11: this is the project's static release binary,
  # pinned by its hash. Replace it with pkgs.rtk when the flake moves to 26.05.
  rtk = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "rtk";
    version = "0.51.0";
    src = pkgs.fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-UCjTsZqPCZDTD+yfuwfjJ4K8VpjmGPsYYarYqcy6TrU=";
    };
    sourceRoot = ".";
    installPhase = "install -Dm755 rtk $out/bin/rtk";
    meta.platforms = [ "x86_64-linux" ];
  };
in
{
  #
  # Nix
  #

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  #
  # Time & internationalisation
  #

  time.timeZone = "Europe/Amsterdam";

  # English messages, Dutch formats: the same split as ~/.zshrc. Not LC_NUMERIC and
  # LC_MONETARY: a decimal comma breaks scripts that print or parse numbers.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  #
  # Shell & editor (their configuration comes from the dotfiles)
  #

  programs.zsh = {
    enable = true;
    # The plugin manager in ~/.zshrc already runs compinit
    enableGlobalCompInit = false;
  };
  # `chsh` does not stick on NixOS
  users.defaultUserShell = pkgs.zsh;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  #
  # Packages
  #

  environment.systemPackages = with pkgs; [
    bubblewrap # Sandbox for dotfiles-dev (see the README)
    claude-code
    git
    gitleaks # Scans commits in the dotfiles pre-commit hook
    gnupg
    jq
    nodejs
    pnpm
    rtk
    typescript-language-server # For the Claude Code plugin typescript-lsp
    unzip
    wget
  ];
}
