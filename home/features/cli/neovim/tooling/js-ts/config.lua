return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				vtsls = {
					settings = {
						typescript = {
							tsserver = {
								maxTsServerMemory = 8192,
								nodePath = vim.fn.exepath("node"),
							},
							preferences = {
								includePackageJsonAutoImports = "off",
							},
						},
						javascript = {
							tsserver = {
								maxTsServerMemory = 8192,
								nodePath = vim.fn.exepath("node"),
							},
							preferences = {
								includePackageJsonAutoImports = "off",
							},
						},
					},
				},
			},
		},
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"AkisArou/neotest-nodejs",
		},
		opts = {
			adapters = {
				["neotest-nodejs"] = {
					nodeArguments = function(default_args)
						return vim.list_extend({ "--import", "tsx" }, default_args)
					end,
					cwd = function(path)
						local start = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
						local package_json = vim.fs.find("package.json", { path = start, upward = true })[1]

						return package_json and vim.fs.dirname(package_json) or vim.uv.cwd()
					end,
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "css", "scss" })
		end,
	},
}
