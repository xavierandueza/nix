{
  pkgs,
  inputs,
  ...
}:
let
  herdr = inputs.llm-agents.packages.${pkgs.system}.herdr;
in
{
  home.packages = [ herdr ];
}
