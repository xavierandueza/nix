{ pkgs }:

let
  version = "1.1.0";
  releaseUrl = "https://github.com/anamaydev/advanced-line-numbers/releases/download/${version}";
in
pkgs.linkFarm "obsidian-advanced-line-numbers-${version}" [
  {
    name = "main.js";
    path = pkgs.fetchurl {
      url = "${releaseUrl}/main.js";
      hash = "sha256-WNq8+LJLoHHN2YBqjlSZGiEPc/VTYFXM3yHMpBCF1iQ=";
    };
  }
  {
    name = "manifest.json";
    path = pkgs.fetchurl {
      url = "${releaseUrl}/manifest.json";
      hash = "sha256-w1P1qaEFGJ1KydJDbL1hxSp0/Q+mPS1QL/weU3OepP4=";
    };
  }
  {
    name = "styles.css";
    path = pkgs.fetchurl {
      url = "${releaseUrl}/styles.css";
      hash = "sha256-BpCklPDZXYarQHXPF8GX5FjmLOsAN0MyVLVaq7dwaPk=";
    };
  }
]
