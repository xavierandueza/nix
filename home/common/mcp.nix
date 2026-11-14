{
  pkgs,
  inputs,
  lib,
  osConfig,
  ...
}:
let
  sharedConfig = builtins.fromJSON (builtins.readFile (inputs.agents + "/mcp.json"));
  langfuse = pkgs.writeShellApplication {
    name = "langfuse-mcp";
    runtimeInputs = [ pkgs.nodejs_22 ];
    text = ''
      exec npx -y mcp-remote \
        https://us.cloud.langfuse.com/api/public/mcp \
        --header-file ${lib.escapeShellArg osConfig.sops.secrets.langfuse-mcp-headers.path}
    '';
  };
in
{
  # Preserve shared settings and other servers, but replace the entire Langfuse
  # entry so no legacy inline credential is copied into the generated JSON.
  home.file.".config/mcp/mcp.json".text = builtins.toJSON (
    sharedConfig
    // {
      mcpServers = (sharedConfig.mcpServers or { }) // {
        langfuse = {
          command = lib.getExe langfuse;
          args = [ ];
        };
      };
    }
  );
}
