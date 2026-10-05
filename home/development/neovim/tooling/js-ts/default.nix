{
  lazyvimCustomPlugins,
  pkgs,
  ...
}:
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
          ''{ "marilari88/neotest-vitest", dir = "${pkgs.vimPlugins.neotest-vitest}" }''
        ]
        (builtins.readFile ./config.lua);
    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      css
      scss
    ];
  };
}
