{ pkgs, ... }:
let
  playwrightCliSource = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "3a1bafc8b4e973c72d0364eb5b427d1ce0aa8317";
    hash = "sha256-hHK/GR5Drlt+e0L9kyNmn+ht1PCrVH6WrVbxGB1Wsxg=";
  };

  playwrightCli = pkgs.buildNpmPackage {
    pname = "playwright-cli";
    version = "0.1.13";

    src = playwrightCliSource;

    npmDepsHash = "sha256-Ulp6IttsZcOOA7LaYDpVKkBYbe2j4RFG8lJARWifOSk=";
    dontNpmBuild = true;
  };
in
{
  packages = [ playwrightCli ];

  skills.playwright-cli = "${playwrightCliSource}/skills/playwright-cli";
}
