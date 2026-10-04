# GNOME: display manager, desktop, extensions and GTK apps. Import next to desktop.nix.
{ pkgs, ... }:

{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome = {
    gnome-browser-connector.enable = true;
    gnome-settings-daemon.enable = true;
  };
  # Media Transfer Protocol (MTP)
  services.gvfs.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    gnome-music
    gnome-system-monitor
  ];

  # Qt apps with the Adwaita theme
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer" # Fractional scaling (125%, 150%, 175%)
              "variable-refresh-rate" # Variable refresh rate (VRR) on compatible displays
              "xwayland-native-scaling" # Crisp Xwayland apps on HiDPI screens
              "autoclose-xwayland" # Stop Xwayland when the last X11 client is gone
            ];
          };
          "org/gnome/desktop/interface" = {
            text-scaling-factor = 1.25;
          };
        };
      }
    ];
  };

  # GSConnect is KDE Connect for GNOME
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  environment.systemPackages = with pkgs; [
    evolution-data-server
    gnome-boxes
    gnome-builder
    gnome-podcasts
    gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.just-perfection
    gnomeExtensions.keyboard-modifiers-status
    gnomeExtensions.places-status-indicator
    gnomeExtensions.tiling-shell
    lollypop
    resources
    shortwave
    switcheroo
    textpieces
    tuba
  ];
}
