{ config, lib, pkgs, ... }:
let
  npmNoFund = [ "--no-fund" ];

  gitnexus = pkgs.buildNpmPackage {
    pname = "gitnexus";
    version = "1.6.5";

    src = pkgs.fetchFromGitHub {
      owner = "abhigyanpatwari";
      repo = "GitNexus";
      rev = "42d4fcaf6fc3bedb0fc9eb97230638e848a9d9af";
      hash = "sha256-bNV6yhbMbCYmkSu67dEF3Pm4amgzXNopWk+G2fmkdpI=";
    };

    sourceRoot = "source/gitnexus";
    npmDepsHash = "sha256-5raY6QPxrMev3e5CftFSCLir91UwWlTAvp6t5por3r4=";
    ONNXRUNTIME_NODE_INSTALL = "skip";
    npmFlags = npmNoFund;
    npmPackFlags = npmNoFund;
    npmPruneFlags = npmNoFund;
    postPatch = ''
      chmod -R u+w ../gitnexus-shared
      substituteInPlace scripts/build.js \
        --replace-fail "path.join('node_modules', '.bin', 'tsc')" "path.join(ROOT, 'node_modules', '.bin', 'tsc')" \
        --replace-fail "if (fs.existsSync(path.join(WEB_ROOT, 'package.json')))" "if (false)"
    '';
    dontNpmBuild = true;
  };

  trustedProjects = [
    # Seekube
    "${config.home.homeDirectory}/repo/seekube/amibuilder"
    "${config.home.homeDirectory}/repo/seekube/backend"
    "${config.home.homeDirectory}/repo/seekube/chore"
    "${config.home.homeDirectory}/repo/seekube/cookie-consent"
    "${config.home.homeDirectory}/repo/seekube/data-aggregator"
    "${config.home.homeDirectory}/repo/seekube/front"
    "${config.home.homeDirectory}/repo/seekube/go-api"
    "${config.home.homeDirectory}/repo/seekube/infra"
    "${config.home.homeDirectory}/repo/seekube/jack"
    "${config.home.homeDirectory}/repo/seekube/redash-related-scripts"
    "${config.home.homeDirectory}/repo/seekube/staging"
    "${config.home.homeDirectory}/repo/seekube/ui"
    "${config.home.homeDirectory}/repo/seekube/ui-kit"

    # Unyka
    "${config.home.homeDirectory}/repo/unyka"
    #
    # Personal
    "${config.home.homeDirectory}/.config/nixos"
    "${config.home.homeDirectory}/.config/nvim"
  ];

  projects = lib.genAttrs trustedProjects (_: { trust_level = "trusted"; });
in {
  home.packages = [
    gitnexus
    pkgs.uv
  ];

  programs.codex = {
    enable = true;
    settings = {
      model = "gpt-5.5";
      review_model = "gpt-5.5";
      model_provider = "openai";

      features = {
        memories = true;
        js_repl = true;
      };

      mcp_servers = {
        gitnexus = {
          command = "${gitnexus}/bin/gitnexus";
          args = [ "mcp" ];
        };

        serena = {
          startup_timeout_sec = 15;
          command = "${pkgs.uv}/bin/uvx";
          args = [
            "--from"
            "git+https://github.com/oraios/serena"
            "serena"
            "start-mcp-server"
            "--project-from-cwd"
            "--context=codex"
          ];
        };
      };

      inherit projects;
    };
  };
}
