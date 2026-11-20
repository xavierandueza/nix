{ pkgs, osConfig, ... }:

{
  home.packages = [
    pkgs.bluetui
    pkgs.wl-clipboard
    pkgs.google-cloud-sdk
  ];

  programs = {
    impala.enable = true;
    wiremix.enable = true;

    docker-cli = {
      enable = true;
      contexts.rootless.Endpoints.docker.Host =
        "unix:///run/user/${toString osConfig.users.users.xavier.uid}/docker.sock";
      settings.currentContext = "rootless";
    };
  };
}
