{
  config,
  lib,
  pkgs,
  ...
}:

let
  rsaKey = "${config.xdg.stateHome}/wayvnc/rsa_key.pem";
  input = config.wayland.windowManager.hyprland.settings.config.input;
in
{
  services.wayvnc = {
    enable = true;
    autoStart = true;
    settings = {
      # Only reachable over Tailscale; the firewall blocks 5900 elsewhere
      address = "0.0.0.0";
      port = 5900;
      enable_auth = true;
      enable_pam = true;
      rsa_private_key_file = rsaKey;
      # Must match Hyprland's layout or remote keystrokes land on the wrong keys
      xkb_layout = input.kb_layout;
      xkb_variant = input.kb_variant;
    };
  };

  systemd.user.services.wayvnc.Service.ExecStartPre = pkgs.writeShellScript "wayvnc-rsa-key" ''
    if [ ! -f ${rsaKey} ]; then
      mkdir -p -m 700 ${dirOf rsaKey}
      ${lib.getExe' pkgs.openssh "ssh-keygen"} -q -m pem -t rsa -N "" -f ${rsaKey}
    fi
  '';
}
