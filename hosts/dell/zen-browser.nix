{ pkgs, inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs = {
    zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
      profiles = {
        default = {
          mods = [
            "c01d3e22-1cee-45c1-a25e-53c0f180eea8" # Ghost Tabs
            "e122b5d9-d385-4bf8-9971-e137809097d0" # No top sites
            "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scroll
          ];
          search = {
            force = true; # Enforce declared search engines on each rebuild
            default = "ddg";
            engines = {
              mynixos = {
                name = "My NixOS";
                urls = [
                  {
                    template = "https://mynixos.com/search?q={searchTerms}";
                    params = [
                      {
                        name = "query";
                        value = "searchTerms";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nx" ];
              };
              github = {
                name = "GitHub Search";
                urls = [
                  {
                    template = "https://github.com/search?q={searchTerms}";
                  }
                ];
                definedAliases = [ "@gh" ];
              };
            };
          };
          containersForce = true;
          containers = {
            personal = {
              id = 1;
              color = "blue";
              icon = "fingerprint";

            };
            work = {
              id = 2;
              color = "purple";
              icon = "briefcase";
            };
          };
          pinsForce = true;
          pinsForceAction = "remove";
          spacesForce = true;
          spaces = {
            "Personal" = {
              id = "c6de089c-410d-4206-961d-ab11f988d40a";
              position = 1000;
              icon = "🟦";
              theme = {
                type = "gradient";

                colors = [
                  {
                    red = 42;
                    green = 100;
                    blue = 155;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                  {
                    red = 87;
                    green = 154;
                    blue = 199;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                  {
                    red = 79;
                    green = 176;
                    blue = 213;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                ];
              };
              pins = {
                "Linear" = {
                  id = "c2f67572-fe7a-48d2-a632-c2d904b57093";
                  url = "https://linear.app/";
                  position = 100;
                  isEssential = true;
                };
                "Email" = {
                  id = "5e8db6a4-92c7-4f31-8a60-1b9f3ce47d28";
                  url = "https://mail.google.com";
                  position = 200;
                  isEssential = true;
                };
                "Calendar" = {
                  id = "faef6165-f4e8-41cc-b64b-0af980504d77";
                  url = "https://calendar.notion.so/";
                  position = 300;
                  isEssential = true;
                };
                "Engine PRs" = {
                  id = "f729765c-38e4-4e92-9dbc-f3c66c6e75d5";
                  url = "https://github.com/transition-zero-app/transition_zero_engine/pulls";
                  position = 400;
                  isEssential = true;
                };
                "1Password" = {
                  id = "60dd1a48-cf58-4530-9da4-219927a7dfd9";
                  url = "https://my.1password.com/";
                  position = 500;
                  isEssential = true;
                };
                "Loom" = {
                  id = "92a2379e-5363-4cb3-a62e-802ad30a9a33";
                  url = "https://www.loom.com/looms/videos";
                  position = 600;
                  isEssential = true;
                };
              };
            };
            "Work" = {
              id = "cdd10fab-4fc5-494b-9041-325e5759195b";
              position = 2000;
              icon = "🟪";
              theme = {
                type = "gradient";

                colors = [
                  {
                    red = 100;
                    green = 42;
                    blue = 155;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                  {
                    red = 126;
                    green = 87;
                    blue = 199;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                  {
                    red = 114;
                    green = 83;
                    blue = 237;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                ];
              };

            };
            "t0" = {
              id = "02e2b979-eab0-4d0e-b067-d84234099768";
              position = 3000;
              icon = "🟧";
              theme = {
                type = "gradient";

                colors = [
                  {
                    red = 155;
                    green = 70;
                    blue = 20;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                  {
                    red = 214;
                    green = 110;
                    blue = 40;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                  {
                    red = 245;
                    green = 150;
                    blue = 60;
                    algorithm = "floating";
                    type = "explicit-lightness";
                    lightness = 50;
                  }
                ];
              };
            };
          };
        };
      };
      policies =
        let
          mkExtensionSettings = builtins.mapAttrs (
            _: pluginId: {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
              installation_mode = "force_installed";
            }
          );
        in
        {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          ExtensionSettings = mkExtensionSettings {
            "uBlock0@raymondhill.net" = "ublock-origin";
            "nordpassStandalone@nordsecurity.com" = "nordpass-password-management";
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
          };
        };
    };
  };
}
