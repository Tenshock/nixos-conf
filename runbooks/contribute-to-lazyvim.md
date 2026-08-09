# Contribute Local Neovim Improvements To LazyVim

This runbook turns the useful parts of the local Neovim configuration into
small, reviewable LazyVim contributions. It does not migrate the production
configuration to `lazyvim-nix`; that separate decision is covered by
[`evaluate-lazyvim-nix.md`](./evaluate-lazyvim-nix.md).

The recommended order is:

1. fix local correctness problems that would otherwise corrupt the evidence;
2. submit the TypeScript debug-adapter compatibility fix;
3. propose a Hyprland language extra;
4. propose opt-in Nix and .NET language-server choices;
5. keep personal preferences and immature integrations local.

One concern belongs in one issue or pull request. Do not combine the candidates
in this runbook into a single upstream change.

## 1. Current Snapshot

This snapshot was verified on 2026-08-10.

The repository lock file contains:

```json
"LazyVim": {
  "branch": "main",
  "commit": "c10948c50b18fae7f256433afdef09e432410480"
}
```

That commit is LazyVim `v16.0.0` and is also tagged `stable`. The GitHub
release notes are dated 2026-05-27; the release commit was published on
2026-06-02. At the time of the audit, upstream `main` was one commit ahead at
`459a4c3b1059671e766a46c7cc223827dc67e3d0`, and the only upstream difference
was generated Vim documentation. Recheck this before every contribution.

The local architecture is intentionally hybrid:

- Nix owns Neovim, runtimes, LSP servers, formatters, linters, and command-line
  dependencies;
- lazy.nvim owns plugins and `lazy-lock.json`;
- LazyVim core is imported first, LazyVim extras next, and local plugin
  overrides last;
- ecosystem configuration lives under
  `home/features/cli/neovim/tooling/<ecosystem>/`.

## 2. Safety And Scope

Start in the NixOS repository and inspect its state:

```sh
cd /home/cedric/.config/nixos
git status --short
```

Do not touch unrelated dirty files. At the time this runbook was written,
`flake.nix` and `hosts/framework-13/configuration.nix` were already modified;
recheck rather than assuming this remains true.

Use a separate checkout for LazyVim. Do not develop upstream changes inside
the production Neovim tree. Do not run `nixos-rebuild switch` or Home Manager
activation as part of upstream development. Evaluation and builds do not
activate the result.

Publishing a branch, issue, or pull request changes external state. Review the
final diff and request explicit approval before publication.

## 3. Understand The Update Boundary

The local lazy.nvim configuration uses `defaults.version = false`, and the
LazyVim spec has no explicit version. Consequently, an update considers the
head of LazyVim's `main` branch. `lazy-lock.json` freezes the selected commit
between updates.

`checker.enabled = true` only checks for newer commits. With `notify = false`,
it neither updates plugins nor displays update notifications.

Use these commands inside Neovim deliberately:

```vim
:Lazy update LazyVim
:Lazy update
:Lazy sync
:Lazy restore
```

- `update LazyVim` updates only LazyVim and rewrites its lock entry;
- `update` updates all eligible plugins and rewrites the lock file;
- `sync` installs missing plugins, cleans removed plugins, and updates;
- `restore` returns plugin checkouts to the locked revisions.

The lock file is a writable out-of-store symlink to the Nix repository.
Therefore, a Lazy update directly changes
`home/features/cli/neovim/lazy-lock.json`. A Nix rebuild does not update lazy
plugin checkouts.

Before and after an intentional update, capture:

```sh
jq '.LazyVim' home/features/cli/neovim/lazy-lock.json
git diff -- home/features/cli/neovim/lazy-lock.json
git -C /home/cedric/.local/share/nvim/lazy/LazyVim rev-parse HEAD
git -C /home/cedric/.local/share/nvim/lazy/LazyVim describe --tags --always
```

## 4. Refresh Upstream And Search For Duplicates

Create or refresh a disposable checkout:

```sh
git clone https://github.com/LazyVim/LazyVim.git /tmp/lazyvim-upstream
cd /tmp/lazyvim-upstream
git fetch origin
git switch main
git pull --ff-only
git rev-parse HEAD
git log -1 --format='%cs %s'
```

If the directory already exists, skip `git clone`. Before coding, search the
current source, issues, and pull requests:

```sh
rg -n "js-debug-adapter|hyprland|hyprls|nixd|nil_ls|roslyn_ls|leetcode" lua tests
gh search issues --repo LazyVim/LazyVim --state open "js-debug"
gh search issues --repo LazyVim/LazyVim --state open "hyprland OR hyprls"
gh search issues --repo LazyVim/LazyVim --state open "nixd OR nil_ls"
gh search issues --repo LazyVim/LazyVim --state open "roslyn_ls OR roslyn"
gh search prs --repo LazyVim/LazyVim --state open \
  "js-debug OR hyprland OR nixd OR roslyn"
```

Read the current `CONTRIBUTING.md` and pull-request template. LazyVim currently
requires language extras to have a `recommended` section, use the broadly
adopted language tools, remain user-overridable, and lazy-load plugins
properly. Plugin extras must be well-known and require meaningful
configuration.

## 5. Correct Local Evidence First

These local problems must not be presented as proof of missing LazyVim
features. Fix and validate them locally in separate changes when relevant:

1. `plugins/blink-cmp.lua` replaces the complete `opts.sources` table and can
   discard inherited providers such as `lazydev`; filter items through
   `sources.transform_items` instead.
2. `tooling/yaml/config.lua` restricts yamlls to Helm filetypes, which disables
   normal YAML support.
3. `tooling/markdown/config.lua` references the foreign absolute path
   `/home/pcino/.markdownlint-cli2.yaml`.
4. Codex plugin auto-installation and Leetcode's runtime `:TSUpdate html`
   conflict with the intended Nix ownership boundary.

The .NET build-on-open traversal, minimal Go and Typst specs, redundant local
refactoring spec, and overlapping `image.nvim` integration were removed on
2026-08-10. The configuration now uses LazyVim's mature .NET, Go, Typst, and
refactoring extras, Roslyn for C#, and Snacks for image rendering. Their active
external tools remain Nix-owned because Mason is disabled locally.

Do not bundle these local cleanups into an upstream LazyVim pull request.

## 6. PR 1: Support Nixpkgs' TypeScript Debug Adapter

### Problem

LazyVim's TypeScript extra currently uses:

```lua
command = "js-debug-adapter"
```

Mason installs that executable name. Nixpkgs' `vscode-js-debug` package instead
provides `js-debug`, whose entry point launches `dapDebugServer.js`. A Nix-owned
installation therefore fails unless a local adapter override is kept.

### Small Upstream Fix

Change only the command selection in
`lua/lazyvim/plugins/extras/lang/typescript/init.lua`:

```lua
command = vim.fn.executable("js-debug") == 1 and "js-debug" or "js-debug-adapter"
```

The order is significant. Prefer the system `js-debug` executable when it is
already on `PATH`; otherwise retain `js-debug-adapter` so a future Mason
installation still works.

### Verification

Test both paths:

1. with only Nixpkgs `js-debug` on `PATH`, confirm the adapter starts;
2. without `js-debug`, confirm the configuration still selects
   `js-debug-adapter` for Mason;
3. open a TypeScript project, set a breakpoint, start a debug session, and
   confirm the client reaches the breakpoint;
4. confirm the TypeScript extra remains lazy and no adapter process starts
   merely by launching Neovim.

Suggested title:

```text
fix(typescript): support the js-debug executable
```

This is the only candidate currently ready for a direct pull request without a
prior design discussion.

## 7. Proposal 2: Add A Hyprland Language Extra

Open a feature proposal before coding. Existing `util.dot` already assigns
files under a Hypr directory to `hyprlang` and conditionally installs the
Hyprland Tree-sitter parser, but it does not configure `hyprls`.

Propose `lua/lazyvim/plugins/extras/lang/hyprland.lua` containing:

- a `recommended` predicate for `hyprlang` buffers and recognizable Hyprland
  roots;
- robust filetype detection for `hyprland.conf` and included files such as
  `monitors.conf`, not only `hypr*.conf` and `*.hl`;
- the `hyprlang` Tree-sitter parser;
- `hyprls` in `nvim-lspconfig` servers;
- no manual `LspStart`, `LspAttach`, or restart autocmds.

Resolve root detection before submitting. The current nvim-lspconfig
`hyprls` definition uses only `.git` as a root marker, while real Hyprland
configurations commonly live in `~/.config/hypr` without Git metadata. Evaluate
`hyprland.conf` and `.hyprlsignore` as root markers, and coordinate with
nvim-lspconfig if the correct fix belongs there.

Test this matrix:

<!-- markdownlint-disable MD013 -->

| Case | Expected result |
| --- | --- |
| `~/.config/hypr/hyprland.conf`, no Git repository | One `hyprls` client attaches |
| Included `monitors.conf` | Filetype is `hyprlang`; same root and client are reused |
| Hyprland config inside a Git repository | Repository-local client attaches |
| `.hyprlsignore` present | Root and ignore behavior are respected |
| `hyprls` supplied by Mason | Extra works without Nix-specific configuration |
| `hyprls` supplied on `PATH` | Extra works without Mason ownership |
| Ordinary `.conf` outside a Hyprland tree | No false Hyprland classification |

<!-- markdownlint-enable MD013 -->

Do not upstream the current local autocmd. It has narrow patterns, assumes the
working directory is the project root, and bypasses LazyVim's LSP lifecycle.

## 8. Proposal 3: Make `nixd` An Opt-In Nix LSP

LazyVim's Nix extra currently defaults to `nil_ls`, with `nixfmt` and `statix`.
Keep that default: Mason supports `nil`, while it does not currently provide
`nixd`, and changing the default would regress zero-configuration users.

Propose an overridable selector, following an existing alternative-LSP pattern:

```lua
vim.g.lazyvim_nix_lsp = "nil_ls"
```

Accepted values should include at least `nil_ls` and `nixd`. Enabling one must
disable the other. A nested opt-in extra is acceptable if maintainers prefer
that API over a global selector.

Test:

- the default still installs and enables `nil_ls` through Mason;
- selecting `nixd` enables a system executable found on `PATH`;
- exactly one Nix LSP attaches;
- formatter and linter behavior remains unchanged;
- a missing selected executable produces ordinary, understandable LSP health
  output instead of enabling both servers.

Suggested proposal title:

```text
feat(nix): allow opting into nixd while keeping nil_ls as default
```

## 9. Proposal 4: Add An Opt-In Roslyn Server For .NET

LazyVim's existing .NET extra is already broad: OmniSharp, extended
definitions, `fsautocomplete`, CSharpier/Fantomas, `netcoredbg`,
`neotest-vstest`, and relevant parsers. Do not replace it wholesale.

Current nvim-lspconfig and Mason support `roslyn_ls`. Propose Roslyn as an
opt-in C# server while retaining:

- OmniSharp as the compatibility default unless maintainers decide otherwise;
- `fsautocomplete` for F#;
- working VB behavior;
- existing format, debug, and test integrations.

Validate with a real multi-project solution, a single-project directory, C#,
F#, and VB. Confirm only one C# LSP attaches. Do not include the local automatic
build-on-open or LSP restart logic.

## 10. Optional Proposal: Leetcode Extra

Only open this proposal after the four higher-value candidates. The
`kawre/leetcode.nvim` plugin has enough configuration surface to be considered,
but the local spec is not upstream-ready.

An upstream version must:

- lazy-load on `:Leet` or equivalent explicit entry points;
- avoid `:TSUpdate` build hooks because parser ownership may be external;
- use LazyVim's picker abstraction instead of forcing Telescope;
- omit personal language choices and keymaps;
- document why the plugin meets LazyVim's adoption and configuration threshold.

Ask maintainers whether they want this extra before implementing it.

## 11. Keep These Changes Local

Do not propose these from the current configuration:

<!-- markdownlint-disable MD013 -->

| Customization | Reason |
| --- | --- |
| `AkisArou/neotest-nodejs` | Very low adoption and maturity; does not meet the language-extra bar |
| `smart-splits.nvim` local spec | Too little substantial LazyVim-specific configuration |
| `image.nvim` | Backend and dependency variability, plus overlap with Snacks images |
| Personal Codex fork | Personal integration and Nix ownership conflict |
| Autosave, themes, cursorword, statusline, bufferline, Neo-tree, dashboard preferences | User preference, not a missing framework capability |
| Docker, Helm, Markdown, Python, Rust, SQL, Terraform, TOML, YAML | Appropriate LazyVim extras already exist |
| Lua | Already handled by LazyVim core |

<!-- markdownlint-enable MD013 -->

## 12. Validate Every Upstream Branch

Run the checks from the LazyVim checkout:

```sh
cd /tmp/lazyvim-upstream
stylua --check lua
if /bin/grep --line-number -r -P '^(?!\s*--).*\bdd\(' lua; then
  echo 'debug messages found'
  false
fi
./scripts/test
git diff --check
git status --short
```

These reproduce the current upstream CI's Stylua, debug-call, and test jobs.
`./scripts/test` may download lazy.nvim and test dependencies into `.tests` on
the first run. The upstream repository contains `selene.toml`, but the current
shared CI workflow does not run Selene. It may still be used as an additional
local check:

```sh
selene lua
```

For changes involving an LSP or debug adapter, automated spec tests are
necessary but not sufficient. Complete the runtime matrix in the relevant
section and record exact `:LspInfo`, `:checkhealth`, or DAP results in the pull
request.

## 13. Prepare And Publish One Contribution

Review the branch before publication:

```sh
git status --short
git diff --stat origin/main...HEAD
git diff --check origin/main...HEAD
git log --oneline --decorate origin/main..HEAD
```

The pull request must include:

- one concrete problem and reproduction;
- why the change belongs in LazyVim rather than a personal config;
- compatibility behavior for Mason and system-managed executables;
- automated checks run and their results;
- runtime tests run and their results;
- the related issue for proposals requiring design agreement.

Do not claim CI is green until all required checks have completed successfully.
Do not treat skipped or cancelled required jobs as successful.

## 14. Consume An Upstream Fix Locally

After merge, update only LazyVim first:

```vim
:Lazy update LazyVim
```

Then inspect the repository change:

```sh
cd /home/cedric/.config/nixos
jq '.LazyVim' home/features/cli/neovim/lazy-lock.json
git diff -- home/features/cli/neovim/lazy-lock.json
git -C /home/cedric/.local/share/nvim/lazy/LazyVim log -1 --oneline --decorate
```

Remove the corresponding local workaround in a separate commit, then repeat
its runtime test. If only Lua plugin configuration and the lock file changed,
a NixOS build is not what proves the runtime behavior; restart Neovim and test
the actual filetype or debug session.

If Nix module files or `extraPackages` also changed, validate without switching:

```sh
cd /home/cedric/.config/nixos
nix eval --impure path:.#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix build --impure path:.#checks.x86_64-linux.nixos
git diff --check
```

Stop after evaluation and build. Ask the machine owner to switch the
configuration, restart Neovim, and report the live result before declaring the
Nix-owned runtime change active.

## 15. Completion Criteria

A candidate is complete only when:

- its upstream duplicate search was refreshed;
- maintainers accepted the design when a proposal was required;
- one focused branch contains the implementation and tests;
- upstream-equivalent checks pass;
- the relevant real runtime matrix passes;
- the pull request accurately states its scope and evidence;
- after merge, the local workaround is removed and the lock update is reviewed;
- any Nix change is evaluated and built separately from activation;
- the production Neovim runtime is verified after the owner switches or
  restarts it.
