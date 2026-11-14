{ pkgs, ... }:

{
  services = {
    mako = {
      enable = true;

      extraConfig = ''
        max-history=10

        # Keep notifications until dismissed, even if the sender requests a timeout.
        default-timeout=0
        ignore-timeout=1

        # Layout
        width=250

        # Tokyo Night Moon
        background-color=#222436
        text-color=#c8d3f5
        border-color=#82aaff
        progress-color=over #444a73

        # Media key popups (see ./media-keys) are short-lived.
        [app-name=volume]
        default-timeout=2000

        [app-name=brightness]
        default-timeout=2000
      '';
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    -- Notifications: dismiss one/all, restore, and invoke the default action.
    hl.bind("SUPER + COMMA", hl.dsp.exec_cmd("${pkgs.mako}/bin/makoctl dismiss"));
    hl.bind("SUPER + SHIFT + COMMA", hl.dsp.exec_cmd("${pkgs.mako}/bin/makoctl dismiss --all"));
    hl.bind("SUPER + CTRL + COMMA", hl.dsp.exec_cmd("${pkgs.mako}/bin/makoctl restore"));
    hl.bind("SUPER + PERIOD", hl.dsp.exec_cmd("${pkgs.mako}/bin/makoctl invoke"));
  '';
}
