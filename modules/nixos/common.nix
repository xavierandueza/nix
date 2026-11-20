{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../shared/secrets.nix
    ./tailscale.nix
    ./ssh.nix
    ./wayvnc.nix
    ./nix-access-tokens.nix
    inputs.work.nixosModules.default
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.hyprland.enable = true;
  security.pam.services.hyprlock = { };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${lib.getExe' pkgs.tuigreet "tuigreet"} --cmd start-hyprland";
      user = "greeter";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.wireless.iwd = {
    enable = true;
    settings = {
      General.EnableNetworkConfiguration = true;
      Network.NameResolvingService = "systemd";
    };
  };

  # Stay reachable over Tailscale with the lid shut while plugged in
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # Tailscale's preferred Linux DNS
  services.resolved.enable = true;

  # iwd handles DHCP; stops dhcpcd fighting it on wlan0
  networking.useDHCP = false;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  time.timeZone = "Australia/Melbourne";

  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "colemak";
    useXkbConfig = false;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.xavier = {
    isNormalUser = true;
    # Pinned because the rootless Docker context hardcodes /run/user/<uid>.
    uid = 1000;
    description = "Xavier";
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
    home = "/home/xavier";
    # Starts user services (the Herdr server) at boot, without a login.
    linger = true;
    # Only applied when the user is first created, since mutableUsers is on.
    hashedPasswordFile = config.sops.secrets.xavier-password.path;
  };

  sops.secrets.xavier-password.neededForUsers = true;

  # Rootless avoids the docker group, which is effectively root access.
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Lets prebuilt binaries (npm/pip/uv, Mason) find a dynamic loader and libs.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
}
