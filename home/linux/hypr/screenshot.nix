{ pkgs, ... }:

{
  home.packages = [
    pkgs.grim
    pkgs.slurp
    pkgs.satty
  ];

  xdg.configFile."satty/config.toml".text = ''
    [general]
    copy-command = "wl-copy"
    output-filename = "~/Pictures/Screenshots/screenshot-%Y-%m-%d_%H-%M-%S.png"
    save-after-copy = true
    actions-on-enter = ["save-to-clipboard"]
    early-exit = ["all"]
  '';
}
