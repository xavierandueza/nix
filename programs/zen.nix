{ inputs, ... }:

{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    darwinDefaultsId = "app.zen-browser.zen";
    setAsDefaultBrowser = true;
  };
}
