{ pkgs }:

pkgs.buildNpmPackage {
  pname = "playwright-cli";
  version = "0.1.18";

  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "ca196c297169a494ee5517584883eada60dc8d0e";
    hash = "sha256-E/AzDJhD12PWSaA3iRY+hloPsSWnAw18gTa/ItVhr3E=";
  };

  npmDepsHash = "sha256-3kqiQvGtZfsmLHVWeCSM1yOYb+ws2x1vMPC1OuvrKAI=";
  dontNpmBuild = true;

  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  postInstall = ''
    mkdir -p "$out/share/playwright-cli"
    cp -r skills "$out/share/playwright-cli/skills"
  '';

  meta = {
    description = "Token-efficient browser automation CLI for coding agents";
    homepage = "https://playwright.dev/agent-cli/introduction";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "playwright-cli";
  };
}
