return {
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			opts.options = {
				separator = "",
				section_separators = { left = "", right = "" },
			}
			opts.sections = {
				lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			}
		end,
	},
}
