{
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  users.users.xavier.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3aD0mgm1ExUmF6VpOQVTrjSi7pffQ+wM37iV3Z47/+ xavier@framework16"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbemigCfIIpc0dhm1lwZDtQdwFN64GN4x+U1yK9bS1E xavier@lyratechnologies.com.au"
  ];
}
