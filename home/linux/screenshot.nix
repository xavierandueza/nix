{ pkgs, ... }:

{
  home.packages = [
    pkgs.grim
    pkgs.slurp
    pkgs.satty
  ];

  systemd.user.tmpfiles.rules = [
    "d %h/screenshots 0755 - - -"
  ];

  xdg.configFile."satty/config.toml".text = ''
    [general]
    copy-command = "wl-copy"
    output-filename = "~/screenshots/%Y-%m-%d_%H-%M-%S.png"
    save-after-copy = true
    actions-on-enter = ["save-to-clipboard"]
    early-exit = ["all"]
  '';
}
