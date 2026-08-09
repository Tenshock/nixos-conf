return {
	{
		"mfussenegger/nvim-lint",
		optional = true,
		opts = {
			linters = {
				["markdownlint-cli2"] = {
					args = { "--config", "/home/pcino/.markdownlint-cli2.yaml", "--" },
				},
			},
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			win_options = {
				conceallevel = { default = 0, rendered = 0 },
			},
		},
	},
}
