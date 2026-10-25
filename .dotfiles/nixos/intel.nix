# Machines with an Intel CPU and its integrated graphics. Import next to base.nix.
# Not in base.nix: on another vendor thermald exits as soon as it starts, and the
# microcode and the graphics drivers here are Intel's own.
{ pkgs, ... }:

{
  #
  # CPU
  #

  # Microcode newer than the BIOS carries, loaded from the initrd at every boot.
  # A firmware update brings its own (see "Firmware updates" in the README), but
  # a BIOS release trails Intel's microcode releases by months.
  hardware.cpu.intel.updateMicrocode = true;

  # thermald steers the CPU away from its thermal limit on its own policy, instead
  # of leaving it to the hardware, which only throttles once it is already too hot.
  # On a thin laptop that is the difference between a slow ramp down and a sudden
  # drop in clock speed. It needs no configuration for a supported Intel CPU.
  services.thermald.enable = true;

  #
  # Graphics
  #

  # Mesa gives Intel OpenGL and Vulkan (iris, anv) but no VA-API: without a driver
  # here, video decoding runs on the CPU, which costs battery life and stutters at
  # 4K. iHD covers Broadwell and newer, and i965 stays as the fallback for what it
  # does not handle. A VDPAU-only application would need libvdpau-va-gl as well;
  # Firefox, Chromium and mpv all speak VA-API.
  #
  # Inert on a machine without hardware.graphics.enable, such as a server.
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
  ];

  # Two drivers are installed, so name the one to use rather than let libva guess
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  environment.systemPackages = with pkgs; [
    libva-utils # `vainfo` names the driver that answers, and the codecs it decodes
  ];
}
