{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  herdr = inputs.llm-agents.packages.${pkgs.system}.herdr;
in
{
  home.packages = [ herdr ];

  # Install the herdr pi integration
  home.activation.installHerdrPiIntegration = lib.hm.dag.entryAfter [ "installPiPackages" ] ''
    $VERBOSE_ARG echo "Installing Herdr Pi integration"
    ${herdr}/bin/herdr integration install pi
  '';

  xdg.configFile."herdr/config.toml".source = "${inputs.herdr-config}/config.toml";
}
