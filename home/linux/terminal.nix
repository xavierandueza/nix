{ pkgs, osConfig, ... }:

{
  home.packages = [ pkgs.bluetui ];

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
