{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    darwinDefaultsId = "app.zen-browser.zen";
    setAsDefaultBrowser = true;

    profiles.default = rec {
      name = "Default (release)";
      path = "ht2wizd2.Default (release)";
      id = 0;
      isDefault = true;

      mods = [
        "c01d3e22-1cee-45c1-a25e-53c0f180eea8"
      ];

      containersForce = true;
      containers = {
        personal = {
          name = "personal";
          color = "blue";
          icon = "circle";
          id = 1;
        };
        lyra = {
          name = "lyra";
          color = "purple";
          icon = "circle";
          id = 2;
        };
      };

      spacesForce = true;
      spaces = {
        lyra = {
          name = "lyra";
          id = "f40cb5ad-dd74-473b-8dbe-b37819acdc70";
          position = 0;
          icon = "🟪";
          container = 2;
          theme = {
            type = "gradient";
            colors = [
              {
                red = 90;
                green = 24;
                blue = 154;
                algorithm = "floating";
                type = "explicit-lightness";
                lightness = 35;
              }
              {
                red = 192;
                green = 132;
                blue = 252;
                algorithm = "analogous";
                type = "explicit-lightness";
                lightness = 70;
              }
            ];
            opacity = 0.8;
            texture = 0.5;
          };
        };
        personal = {
          name = "personal";
          id = "feda0b6e-9ecd-42f2-a82d-5cb0d6924157";
          position = 1;
          icon = "🟦";
          container = 1;
          theme = {
            type = "gradient";
            colors = [
              {
                red = 24;
                green = 82;
                blue = 154;
                algorithm = "floating";
                type = "explicit-lightness";
                lightness = 35;
              }
              {
                red = 132;
                green = 190;
                blue = 252;
                algorithm = "analogous";
                type = "explicit-lightness";
                lightness = 70;
              }
            ];
            opacity = 0.8;
            texture = 0.5;
          };
        };
      };

      pinsForce = true;
      pinsForceAction = "remove";
      pins = {
        "Lyra - Linear" = {
          id = "f4f5a7c1-c2ee-5f86-ae3c-283f5d67f139";
          workspace = spaces.lyra.id;
          url = "https://linear.app/";
          position = 0;
          isEssential = true;
        };
        "Lyra - Gmail" = {
          id = "34f5a211-572a-53b1-8c53-ace207289585";
          workspace = spaces.lyra.id;
          url = "https://mail.google.com/mail/u/0/#inbox";
          position = 1;
          isEssential = true;
        };
        "Lyra - Notion Calendar" = {
          id = "ec14dcbc-bdfc-5d89-b89e-869de859269b";
          workspace = spaces.lyra.id;
          url = "https://calendar.notion.so/";
          position = 2;
          isEssential = true;
        };
        "Lyra - ChatGPT" = {
          id = "a0c7427a-4c7a-53d6-98bd-42520f1438ad";
          workspace = spaces.lyra.id;
          url = "https://chatgpt.com/g/g-p-6a4deddcba5081918b75bf1b7a78f660/project";
          position = 3;
          isEssential = true;
        };
        "Lyra - 1Password" = {
          id = "e8229778-3152-5b0b-b93c-4dcf4e9aefc2";
          workspace = spaces.lyra.id;
          url = "https://my.1password.com/signin";
          position = 4;
          isEssential = true;
        };
        "Lyra - ReadMe Local" = {
          id = "2fc1d598-3ead-57c8-954f-be8a1b209812";
          workspace = spaces.lyra.id;
          url = "http://readme.local:3000/";
          position = 5;
          isEssential = true;
        };
        "Lyra - ReadMe Dashboard" = {
          id = "6afc904b-46cd-5e99-ab19-96d1f017fe0b";
          workspace = spaces.lyra.id;
          url = "https://dash.readme.com/";
          position = 6;
          isEssential = true;
        };
        "Lyra - Localhost 3002" = {
          id = "3a23bf58-309d-551a-bfb6-46690e8d270f";
          workspace = spaces.lyra.id;
          url = "http://localhost:3002/";
          position = 7;
          isEssential = true;
        };
        "Lyra - Localhost 5555" = {
          id = "aaa2c575-ff16-5c3d-b71c-2304e1e1beb1";
          workspace = spaces.lyra.id;
          url = "http://localhost:5555/";
          position = 8;
          isEssential = true;
        };
        "Lyra - AI CLI Runner" = {
          id = "ad0cca3d-07c8-5ea5-8724-35ca11307fca";
          workspace = spaces.lyra.id;
          url = "https://ai-cli-runner.onrender.com/";
          position = 9;
          isEssential = true;
        };
        "Lyra - Langfuse" = {
          id = "b5b38a06-4056-5cb4-aca8-13e187d93a5f";
          workspace = spaces.lyra.id;
          url = "https://us.cloud.langfuse.com/";
          position = 10;
          isEssential = true;
        };
        "Lyra - AI Knowledge" = {
          id = "d39d473f-e9b1-5da4-beeb-24a021a267c6";
          workspace = spaces.lyra.id;
          url = "https://aiknowledge-theta.vercel.app/";
          position = 11;
          isEssential = true;
        };

        "Awaiting Review" = {
          id = "f492ffca-ca17-50f2-8aa6-1c32520cde6b";
          workspace = spaces.lyra.id;
          position = 100;
          isGroup = true;
          isFolderCollapsed = false;
          editedTitle = true;
          folderIcon = "chrome://browser/skin/zen-icons/selectable/eye.svg";
        };
        "Awaiting Review - ReadMe" = {
          id = "290a97b5-0220-5355-b6f1-9561c43ce5eb";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/readme/pulls/review-requested/@me";
          folderParentId = pins."Awaiting Review".id;
          position = 101;
        };
        "Awaiting Review - AI" = {
          id = "a291b7d1-781b-5694-a917-184a7947a227";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/ai/pulls/review-requested/@me";
          folderParentId = pins."Awaiting Review".id;
          position = 102;
        };
        "Awaiting Review - Gitto" = {
          id = "a740413c-633b-5a39-903b-d415aff1e3f2";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/gitto/pulls/review-requested/@me";
          folderParentId = pins."Awaiting Review".id;
          position = 103;
        };
        "Awaiting Review - AI CLI Runner" = {
          id = "049a9c6a-1d7a-53ea-9bd2-b88c626e5d51";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/ai-cli-runner/pulls/review-requested/@me";
          folderParentId = pins."Awaiting Review".id;
          position = 104;
        };
        "Awaiting Review - CLI" = {
          id = "057ac7c8-2a88-5dad-9496-01f07db7ba37";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/cli/pulls/review-requested/@me";
          folderParentId = pins."Awaiting Review".id;
          position = 105;
        };

        "My PRs" = {
          id = "34259395-ceb0-5ea7-b3f0-2aca9e7ba988";
          workspace = spaces.lyra.id;
          position = 200;
          isGroup = true;
          isFolderCollapsed = false;
          editedTitle = true;
          folderIcon = "chrome://browser/skin/zen-icons/selectable/code.svg";
        };
        "My PRs - ReadMe" = {
          id = "5de6b06a-f8f4-5c7a-a9f7-5ee2ea41291b";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/readme/pulls?q=is%3Apr+author%3Axavierandueza+";
          folderParentId = pins."My PRs".id;
          position = 201;
        };
        "My PRs - AI" = {
          id = "5a2282fb-2c34-5fff-80e3-e9b5d7846dc9";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/ai/pulls?q=is%3Apr+author%3Axavierandueza+";
          folderParentId = pins."My PRs".id;
          position = 202;
        };
        "My PRs - Gitto" = {
          id = "91e8809f-6193-5a81-8ecc-b6215faf9f29";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/gitto/pulls?q=is%3Apr+author%3Axavierandueza+";
          folderParentId = pins."My PRs".id;
          position = 203;
        };
        "My PRs - AI CLI Runner" = {
          id = "db7d7081-3327-5062-aa74-a6a84120df58";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/ai-cli-runner/pulls?q=is%3Apr+author%3Axavierandueza+";
          folderParentId = pins."My PRs".id;
          position = 204;
        };
        "My PRs - CLI" = {
          id = "81ceecbc-8559-5887-9537-8df38d951dc1";
          workspace = spaces.lyra.id;
          url = "https://github.com/readmeio/cli/pulls?q=is%3Apr+author%3Axavierandueza+";
          folderParentId = pins."My PRs".id;
          position = 205;
        };

        "Personal - ChatGPT" = {
          id = "9e52c3ec-ada7-510d-bc21-e6797f5f4f1d";
          workspace = spaces.personal.id;
          url = "https://chatgpt.com/projects";
          position = 0;
          isEssential = true;
        };
        "Personal - Gmail" = {
          id = "1688b731-ef8c-5f48-83eb-427431f4e736";
          workspace = spaces.personal.id;
          url = "https://mail.google.com/mail/u/0/#inbox";
          position = 1;
          isEssential = true;
        };
        "Personal - YouTube Music" = {
          id = "45e38d98-c58c-57bc-8947-5930224673ae";
          workspace = spaces.personal.id;
          url = "https://music.youtube.com/";
          position = 2;
          isEssential = true;
        };
        "Personal - YouTube" = {
          id = "401e966b-0b96-5774-8a2f-1808caf25707";
          workspace = spaces.personal.id;
          url = "https://www.youtube.com/";
          position = 3;
          isEssential = true;
        };
        "Personal - Macquarie" = {
          id = "aa9b4ff6-a16b-50f2-a2dc-550ef01fa490";
          workspace = spaces.personal.id;
          url = "https://online.macquarie.com.au/personal/#/login";
          position = 4;
          isEssential = true;
        };
        "Personal - American Express" = {
          id = "d51302e4-12e7-561e-8b9b-646ebbf493bc";
          workspace = spaces.personal.id;
          url = "https://www.americanexpress.com/en-au/account/login";
          position = 5;
          isEssential = true;
        };
        "Personal - LinkedIn" = {
          id = "a2468f84-a200-507e-89cc-47daadf032c5";
          workspace = spaces.personal.id;
          url = "https://www.linkedin.com/feed/";
          position = 6;
          isEssential = true;
        };
        "Personal - WhatsApp" = {
          id = "6c8ac4c5-1664-5717-8f31-dcff97a41af5";
          workspace = spaces.personal.id;
          url = "https://web.whatsapp.com/";
          position = 7;
          isEssential = true;
        };
      };
    };

    policies = {
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
      ExtensionSettings = {
        "nordpassStandalone@nordsecurity.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/nordpass-password-management/latest.xpi";
          installation_mode = "force_installed";
        };
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          installation_mode = "force_installed";
        };
      };
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
  };

  home.activation.registerZenAsDefaultBrowser = lib.hm.dag.entryAfter [ "trampolineApps" ] ''
    zenApp="$HOME/Applications/Home Manager Apps/Zen Browser (Beta).app"
    zenTrampoline="$HOME/Applications/Home Manager Trampolines/Zen Browser (Beta).app"
    lsregister="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

    if [ -e "$zenTrampoline" ]; then
      $DRY_RUN_CMD "$lsregister" -u "$zenTrampoline" || true
      $DRY_RUN_CMD rm -rf "$zenTrampoline"
    fi

    $DRY_RUN_CMD "$lsregister" -f "$zenApp"

    if [ "$(${pkgs.duti}/bin/duti -d http 2>/dev/null)" != "app.zen-browser.zen" ]; then
      $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s app.zen-browser.zen http
    fi

    if [ "$(${pkgs.duti}/bin/duti -d https 2>/dev/null)" != "app.zen-browser.zen" ]; then
      $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s app.zen-browser.zen https
    fi

    if [ "$(${pkgs.duti}/bin/duti -d public.html 2>/dev/null)" != "app.zen-browser.zen" ]; then
      $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s app.zen-browser.zen public.html viewer
    fi
  '';
}
