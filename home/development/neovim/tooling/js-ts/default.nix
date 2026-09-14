{
  lazyvimCustomPlugins,
  pkgs,
  ...
}:
let
  # TOFIX: remove PR https://github.com/marilari88/neotest-vitest/pull/99 workaround once included in the packaged version.
  neotestVitest = pkgs.vimPlugins.neotest-vitest.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      # Vitest 5 joins suite/test names with " > "; older versions use " ".
      substituteInPlace lua/neotest-vitest/init.lua \
        --replace-fail 'local testNamePattern = table.concat(names, " ")' \
          'local testNamePattern = table.concat(vim.tbl_map(escapeTestPattern, names), "\\s(?:>\\s)?")' \
        --replace-fail '"^\\s?" .. escapeTestPattern(testNamePattern)' \
          '"^\\s?" .. testNamePattern'
    '';
  });
in
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      eslint
      nodejs_26
      oxfmt
      prettier
      svelte-language-server
      vscode-js-debug
      vscode-langservers-extracted
      vtsls
    ];

    extras = {
      formatting.prettier.enable = true;
      lang = {
        json.enable = true;
        svelte.enable = true;
        typescript.enable = true;
      };
      linting.eslint.enable = true;
    };
    plugins.tooling-js-ts =
      builtins.replaceStrings
        [
          ''"AkisArou/neotest-nodejs"''
          ''"marilari88/neotest-vitest"''
        ]
        [
          ''{ "AkisArou/neotest-nodejs", dir = "${lazyvimCustomPlugins.neotest-nodejs}" }''
          ''{ "marilari88/neotest-vitest", dir = "${neotestVitest}" }''
        ]
        (builtins.readFile ./config.lua);
    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      css
      scss
    ];
  };
}
