{ ... }:
{
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # Use our provisioned identity, not automatically discovered SSH host keys.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Require a provisioned identity rather than generating a new, unauthorized one.
  sops.age.generateKey = false;
  # Disable using SSH host keys as additional age identities.
  sops.age.sshKeyPaths = [ ];
  # Disable importing SSH host keys for GPG decryption.
  sops.gnupg.sshKeyPaths = [ ];

  sops.secrets.github-token = {
    owner = "xavier";
    mode = "0400";
  };

  sops.secrets.claude-subscription-key = {
    owner = "xavier";
    mode = "0400";
  };

  sops.secrets.langfuse-mcp-headers = {
    owner = "xavier";
    mode = "0400";
  };
}
