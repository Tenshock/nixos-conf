{ pkgs, ... }:
let
  npmNoFund = [ "--no-fund" ];

  gitnexusSource = pkgs.fetchFromGitHub {
    owner = "abhigyanpatwari";
    repo = "GitNexus";
    rev = "42d4fcaf6fc3bedb0fc9eb97230638e848a9d9af";
    hash = "sha256-bNV6yhbMbCYmkSu67dEF3Pm4amgzXNopWk+G2fmkdpI=";
  };

  gitnexus = pkgs.buildNpmPackage {
    pname = "gitnexus";
    version = "1.6.5";

    src = gitnexusSource;
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

  gitnexusSkill =
    name:
    pkgs.runCommand "codex-skill-${name}-${gitnexus.version}" { } ''
      mkdir -p $out
      cp ${gitnexusSource}/gitnexus/skills/${name}.md $out/SKILL.md
    '';
in
{
  packages = [ gitnexus ];

  mcp_servers.gitnexus = {
    command = "${gitnexus}/bin/gitnexus";
    args = [ "mcp" ];
  };

  skills = {
    gitnexus-cli = "${gitnexusSkill "gitnexus-cli"}";
    gitnexus-debugging = "${gitnexusSkill "gitnexus-debugging"}";
    gitnexus-exploring = "${gitnexusSkill "gitnexus-exploring"}";
    gitnexus-guide = "${gitnexusSkill "gitnexus-guide"}";
    gitnexus-impact-analysis = "${gitnexusSkill "gitnexus-impact-analysis"}";
    gitnexus-pr-review = "${gitnexusSkill "gitnexus-pr-review"}";
    gitnexus-refactoring = "${gitnexusSkill "gitnexus-refactoring"}";
  };
}
