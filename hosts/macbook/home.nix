{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../home/common
    ../../home/darwin
    ./obsidian
    ./zen-browser.nix
  ];

  home.username = "xavier";
  home.homeDirectory = "/Users/xavier";
  home.stateVersion = "24.11"; # set once, don't bump casually

  home.sessionVariables = {
    # Disable pi's context-mode's MCP server idle self-shutdown
    # Causes annoying ui issues
    CONTEXT_MODE_BRIDGE_IDLE_MS = "0";
  };

  home.packages = with pkgs; [
    (import ../../packages/anarlog.nix { inherit pkgs; })
    yazi
    colima
    docker # the CLI only — the daemon lives inside colima's VM
    docker-compose # Normal docker doesn't include the code from here
    redis # redis-server + redis-cli
    mongodb-tools
    ngrok
    pnpm
    caddy
    infisical
    worktrunk
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.handy
    terraform
    tigervnc
  ];

  programs.mise = {
    enable = true;
    enableBashIntegration = true;
    globalConfig.tools.node = "22.21.0";
  };

  programs.bash.initExtra = ''
    export PATH="$HOME/.local/bin:$PATH"
    mkcdir() { mkdir -p "$1" && cd "$1"; }
    ssh-add -l &>/dev/null || ssh-add -t 604800 ~/.ssh/id_ed25519
  '';

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      identityFile = "~/.ssh/id_ed25519";
      AddKeysToAgent = "yes";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Xavier Andueza";
        email = "xavier@lyratechnologies.com.au";
      };
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
    };
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
  };

  programs.home-manager.enable = true;

  # Local trust list for verifying SSH-signed commits (git log --show-signature).
  home.file.".ssh/allowed_signers".text = ''
    xavier@lyratechnologies.com.au ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbemigCfIIpc0dhm1lwZDtQdwFN64GN4x+U1yK9bS1E xavier@lyratechnologies.com.au
  '';

  # Make `docker compose` (the plugin subcommand) resolve to `docker-compose`
  home.file.".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
}
