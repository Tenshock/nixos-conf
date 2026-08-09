return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				nil_ls = false,
				nixd = {},
			},
		},
	},
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				nix = { "nixfmt" },
			},
		},
	},
}
