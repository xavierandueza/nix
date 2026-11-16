{
  # wayvnc checks logins against this PAM service
  security.pam.services.wayvnc = { };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5900 ];
}
