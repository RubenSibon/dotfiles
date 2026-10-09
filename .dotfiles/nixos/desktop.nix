# Every machine with a graphical session, whichever desktop environment it runs.
{ pkgs, ... }:

{
  #
  # Networking
  #

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  #
  # Windowing system
  #

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Chromium, Electron and VS Code on Wayland
    MOZ_ENABLE_WAYLAND = "1"; # Firefox; usually already the default
  };

  #
  # Services
  #

  services.printing.enable = true;

  # Sound with PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Flatpak, for apps that should update on their own schedule
  # (Proton Authenticator, Pass, Mail Bridge and VPN, Signal)
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  #
  # Fonts & packages
  #

  fonts.packages = with pkgs; [
    fira
    fira-code
    fira-math
  ];

  programs.firefox = {
    enable = true;
    languagePacks = [ "nl" ];
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  };

  environment.systemPackages = with pkgs; [
    figma-linux
    firefoxpwa
    libreoffice
    libsecret
    nextcloud-client
    spotify
    standardnotes
    thunderbird
    tor-browser
    vivaldi
    vscode-fhs
    vscodium-fhs
  ];
}
