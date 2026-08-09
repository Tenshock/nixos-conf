# Evaluate And Improve `lazyvim-nix`

This runbook evaluates whether
[`pfassina/lazyvim-nix`](https://github.com/pfassina/lazyvim-nix) should replace
the current Neovim architecture, and defines the upstream changes required
before migration.

The current recommendation is:

1. keep the production configuration on the existing hybrid model;
2. contribute focused correctness and composability fixes upstream;
3. test `lazyvim-nix` in isolation;
4. migrate only if the acceptance criteria in this runbook pass.

The current hybrid model is:

- Nix owns Neovim, LSP servers, formatters, linters, runtimes, and CLI tools;
- lazy.nvim owns plugins and `lazy-lock.json`;
- each ecosystem is grouped under
  `home/features/cli/neovim/tooling/<ecosystem>/`;
- LazyVim core loads first, then LazyVim extras, then local plugin overrides.

The upstream audit used `lazyvim-nix` commit
`d1f9bd2bfff35708dfaf75351bce06580a862f61`, containing generated metadata for
LazyVim `v16.0.0`. Recheck upstream before starting work because its generated
plugin and extra metadata changes over time.

## 1. Scope And Safety Rules

Do not replace the production Neovim module during initial evaluation.

Do not activate or switch the NixOS configuration as part of read-only review,
upstream development, or build validation. A successful evaluation or build
does not mean that the configuration was activated.

Do not touch unrelated dirty files. Start every local work session with:

```sh
cd /home/cedric/.config/nixos
git status --short
```

At the time of the original audit, these unrelated files were already dirty:

```text
flake.nix
hosts/framework-13/configuration.nix
```

Recheck rather than assuming that this list is still current.

Keep upstream work in a separate checkout. Do not copy upstream experimental
changes directly into the production NixOS repository.

## 2. Record Current Baseline

Capture the current implementation:

```sh
sed -n '1,260p' home/features/cli/neovim/default.nix
sed -n '1,240p' home/features/cli/neovim/config/lua/lazy.lua
find home/features/cli/neovim/tooling -maxdepth 2 -type f -print | sort
find home/features/cli/neovim/plugins -maxdepth 1 -type f -print | sort
```

Record current plugin lock size and plugin names:

```sh
jq -r 'keys[]' home/features/cli/neovim/lazy-lock.json | sort
jq 'length' home/features/cli/neovim/lazy-lock.json
```

From a running production Neovim, record:

```vim
:Lazy profile
:Lazy health
:checkhealth
:ConformInfo
:LspInfo
```

Test representative files for every ecosystem currently declared under
`tooling/`:

- Docker and Docker Compose;
- .NET;
- Go;
- Helm;
- Hyprland;
- JavaScript and TypeScript;
- Lua;
- Markdown;
- Nix;
- Python;
- Rust;
- shell;
- SQL;
- Terraform;
- TOML;
- Typst;
- YAML.

For each representative file, record:

- attached LSP servers;
- selected formatter;
- selected linter;
- installed tree-sitter parser;
- plugins loaded before opening the file;
- plugins loaded after opening the file.

This baseline is the migration regression contract.

## 3. Refresh Upstream Audit

Use a temporary checkout:

```sh
git clone https://github.com/pfassina/lazyvim-nix.git /tmp/lazyvim-nix-audit
cd /tmp/lazyvim-nix-audit
git rev-parse HEAD
git log -1 --format='%cs %s'
jq -r '.version, .commit, (.plugins | length), .extraction_report' data/plugins.json
```

Inspect the files controlling architecture:

```sh
sed -n '1,390p' nix/module.nix
sed -n '1,380p' nix/options.nix
sed -n '1,240p' nix/lib/plugin-resolution.nix
sed -n '1,220p' nix/lib/file-scanning.nix
sed -n '1,180p' nix/lib/dev-path.nix
sed -n '1,220p' nix/lib/starter-patcher.nix
sed -n '1,260p' nix/lib/treesitter.nix
sed -n '1,240p' .github/workflows/update-plugins.yml
```

Verify whether the problems described below still exist. If upstream already
fixed one, inspect its tests and remove that item from proposed work.

## 4. Upstream Problem 1: Custom Plugin Discovery

### Current problem

At the audited commit, `nix/module.nix` discovers custom plugins by scanning:

```text
${home.homeDirectory}/.config/${appName}/lua/plugins
```

This reads previously activated home state during Nix evaluation instead of
the declared `configFiles` source.

Consequences:

- first build can see no custom plugins;
- adding or removing a plugin can lag by one Home Manager generation;
- evaluation depends on mutable files outside the flake source;
- custom plugin files outside `lua/plugins` are invisible;
- the current `tooling-extras` and `tooling-plugins` directories are invisible;
- regex scanning can treat unrelated quoted `"owner/repository"` strings as
  plugins.

### Reproduction test

Add an integration test using an empty temporary home and a `configFiles`
fixture containing one custom plugin. The evaluated plugin closure must include
that plugin before any activation.

Then change the fixture plugin name without changing the temporary home. The
new evaluation must contain only the new plugin. No previous-generation file
may influence evaluation.

### Preferred design

Make declared source authoritative:

- scan `cfg.configFiles`, not active XDG output;
- parse inline `cfg.plugins` from their declared strings only when needed;
- preferably avoid Lua regex discovery for Nix package ownership;
- add an explicit package mapping option.

Backward-compatible option shape:

```nix
programs.lazyvim.pluginPackages = {
  "someone/plugin.nvim" = pkgs.vimPlugins.plugin-nvim;
};
```

An explicit source derivation is more reliable than guessing a nixpkgs
attribute from a Git repository name. Existing `programs.lazyvim.plugins`
continues to describe lazy.nvim specs and configuration.

### PR boundary

Keep this PR focused on source-driven discovery, explicit package mapping, and
tests. Do not combine it with provider defaults or tree-sitter changes.

## 5. Upstream Problem 2: Strict Plugin Resolution

### Current problem

At the audited commit, `pluginSource = "latest"` can fall back to a nixpkgs
plugin even when its version does not match LazyVim metadata. This makes the
result buildable but violates the option's exact-version promise.

### Preferred design

Use explicit resolution modes:

```nix
programs.lazyvim.pluginSource = "latest";
programs.lazyvim.strictPluginVersions = true;
```

With strict resolution enabled:

- generated LazyVim core and enabled-extra plugins must resolve to the recorded
  revision;
- missing source hashes or unresolved packages must fail evaluation with the
  plugin name and requested revision;
- no silent mismatched nixpkgs fallback is allowed.

Custom user plugins may use a separately documented policy, but the policy
must not weaken core and extra resolution.

### Required tests

Test all three cases:

1. nixpkgs plugin matches requested revision;
2. source build supplies requested revision and hash;
3. neither source matches, therefore strict evaluation fails.

Remove or change the existing test that explicitly expects mismatched nixpkgs
fallback under `pluginSource = "latest"`.

## 6. Upstream Problem 3: Module Composability

### Current problem

At the audited commit, enabling the module directly assigns:

```nix
programs.neovim.package = pkgs.neovim-unwrapped;
programs.neovim.withNodeJs = true;
programs.neovim.withPython3 = true;
programs.neovim.withRuby = false;
```

This can conflict with an existing Home Manager Neovim module.

The `appName` option changes generated paths but does not create a launcher that
sets `NVIM_APPNAME`.

### Preferred design

- Make Neovim package and provider settings explicit `programs.lazyvim`
  options, or use `lib.mkDefault` for defaults.
- Keep user assignments authoritative.
- Either create a wrapped executable setting `NVIM_APPNAME`, or rename
  `appName` to describe only its actual path behavior.
- Add a test combining `programs.lazyvim` with user-selected Neovim package and
  provider values.

Keep package/provider changes separate from custom-plugin discovery unless
upstream maintainer requests one combined PR.

## 7. Upstream Problem 4: Runtime Testing

At the audited commit, tests named `e2e` only verify that Neovim and lazy.nvim
attributes exist in nixpkgs. Add a real Home Manager and Neovim smoke test.

Minimum test requirements:

1. evaluate a Home Manager configuration from an empty home;
2. build its activation package;
3. start generated Neovim with isolated `HOME`, `XDG_CONFIG_HOME`,
   `XDG_DATA_HOME`, `XDG_STATE_HOME`, and `XDG_CACHE_HOME`;
4. run Neovim headlessly;
5. assert that LazyVim and lazy.nvim initialize;
6. assert that a core plugin and enabled-extra plugin resolve from Nix paths;
7. assert that no plugin download is required;
8. open one filetype and verify its lazy-loaded plugin becomes available;
9. exit successfully without attempting writes into `/nix/store`.

Run upstream validation before opening each PR:

```sh
cd /tmp/lazyvim-nix-audit
nix flake check
NIX_PATH=nixpkgs=flake:nixpkgs nix-build test/ -A runAll
git diff --check
```

Report evaluation, build, and runtime results separately in the PR description.

## 8. Preserve Current Tool-Bundle Design

Do not flatten the current ecosystem modules merely to match upstream option
layout. Each current bundle should remain owner of its complete language or
tool experience:

```text
tooling/<ecosystem>/
├── default.nix  # packages and generated XDG files
├── extras.lua   # LazyVim extra imports
└── config.lua   # LSP, formatter, linter, autocmd, or plugin overrides
```

During any future migration, map responsibilities as follows:

- `default.nix` keeps explicit package ownership;
- standard LazyVim imports move to `programs.lazyvim.extras`;
- non-standard plugin specs remain ordinary Lua plugin files;
- overrides remain next to their ecosystem owner;
- generated target paths may become `lua/plugins/tooling-<ecosystem>.lua` if
  upstream only imports the `plugins` namespace.

Do not enable automatic upstream dependency installation globally. Compare its
generated packages against each current `extraPackages` list first. Explicit
current packages remain authoritative until parity is proven.

## 9. Isolated Pilot

Start pilot only after custom plugin discovery and strict resolution are fixed,
or carry reviewed patches in the pinned flake input.

Do not enable `programs.lazyvim` in the production Home Manager module while
the current `programs.neovim` module remains enabled. Both modules own the same
Neovim options and XDG paths.

Build pilot as a separate Home Manager configuration with:

- temporary home directory;
- `appName = "lazyvim-nix-pilot"`;
- explicit `NVIM_APPNAME=lazyvim-nix-pilot` when launching Neovim;
- copied or referenced Lua files, never the production active XDG directory;
- no activation against `/home/cedric`.

Pin inputs and make lazyvim-nix follow this repository's nixpkgs input:

```nix
lazyvim-nix = {
  url = "github:pfassina/lazyvim-nix/<reviewed-commit>";
  inputs.nixpkgs.follows = "nixos";
};
```

Build pilot activation package. Do not activate production:

```sh
nix build --impure path:.#homeConfigurations.lazyvim-nix-pilot.activationPackage
```

If pilot output lives in a separate test flake, run command from that flake and
use its matching output name.

Run pilot with isolated writable directories:

```sh
mkdir -p /tmp/lazyvim-nix-pilot/config
mkdir -p /tmp/lazyvim-nix-pilot/data
mkdir -p /tmp/lazyvim-nix-pilot/state
mkdir -p /tmp/lazyvim-nix-pilot/cache

HOME=/tmp/lazyvim-nix-pilot \
XDG_CONFIG_HOME=/tmp/lazyvim-nix-pilot/config \
XDG_DATA_HOME=/tmp/lazyvim-nix-pilot/data \
XDG_STATE_HOME=/tmp/lazyvim-nix-pilot/state \
XDG_CACHE_HOME=/tmp/lazyvim-nix-pilot/cache \
NVIM_APPNAME=lazyvim-nix-pilot \
nvim --headless '+lua assert(package.loaded.lazy ~= nil)' '+qa'
```

Use the pilot's built Neovim executable when it differs from production
`nvim`.

## 10. Acceptance Criteria

Migration is allowed only when all criteria pass:

- fresh evaluation does not read active `/home/cedric/.config/nvim`;
- first pilot startup needs no Git clone or plugin download;
- all LazyVim core and enabled-extra plugins resolve from `/nix/store`;
- every custom plugin has explicit ownership: Nix package/source or documented
  lazy.nvim fallback;
- strict mode never silently substitutes a different plugin revision;
- tree-sitter parsers and queries match and need no runtime compiler;
- LazyVim import order remains core, extras, then local overrides;
- lazy loading matches baseline for representative filetypes;
- all current LSP servers, formatters, linters, runtimes, and DAP adapters work;
- `:checkhealth`, `:Lazy health`, `:LspInfo`, and `:ConformInfo` contain no new
  failures;
- generated config contains no foreign absolute home paths;
- upstream update procedure is understandable and produces reviewable diffs;
- production NixOS configuration evaluates and builds successfully.

Validate production candidate without switching:

```sh
cd /home/cedric/.config/nixos
nix eval --impure path:.#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix build --impure path:.#checks.x86_64-linux.nixos
git diff --check
```

Building is not activation. Stop after successful build and ask the system
owner to run any switch.

## 11. Migration Procedure

Only after acceptance:

1. add pinned `lazyvim-nix` flake input with `nixpkgs.follows`;
2. import its Home Manager module;
3. convert standard imports from `config/lua/lazy.lua` to typed extras;
4. preserve ecosystem package modules;
5. expose ecosystem overrides inside upstream-supported plugin paths;
6. map every custom plugin to an explicit Nix package or source;
7. replace runtime tree-sitter parser installation with Nix parser ownership;
8. build the NixOS configuration;
9. inspect full diff and store closure;
10. stop and ask the owner to switch;
11. after switch, restart Neovim and rerun runtime baseline;
12. keep prior NixOS generation until runtime validation passes.

Do not remove `lazy-lock.json` during initial migration. Keep it until every
custom plugin has a documented update and rollback path. Delete it only in a
separate reviewed change after proving it is unused.

## 12. Rollback

Before production switch, rollback is deletion or disabling of the candidate
module; current Neovim remains unchanged.

After production switch:

1. close Neovim;
2. select previous NixOS generation or restore previous module selection;
3. switch using the normal host workflow;
4. remove pilot XDG data only after confirming production config works;
5. preserve `lazy-lock.json` and old plugin state until rollback validation
   finishes.

Do not run garbage collection until new configuration survives representative
runtime testing and rollback is no longer needed.

## 13. Final Decision Record

Record final outcome in the PR or commit message:

- upstream commit tested;
- upstream patches carried, if any;
- evaluation command and result;
- build command and result;
- activation performed by owner or not performed;
- live Neovim version and executable path;
- plugin source policy;
- custom plugin exceptions;
- tree-sitter ownership;
- baseline regressions;
- migration accepted, rejected, or deferred.

Default decision remains **defer migration** until custom plugin discovery,
strict plugin resolution, module composability, and real runtime testing are
resolved.
