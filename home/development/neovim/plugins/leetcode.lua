return {
	{
		"kawre/leetcode.nvim",
		build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
		dependencies = {
			"nvim-telescope/telescope.nvim",
			-- "ibhagwan/fzf-lua",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			lang = "rust",
		},
	},
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader>a", group = "LeetCode" },
					{ "<leader>ac", "<cmd>Leet console<cr>", desc = "Console" },
					{ "<leader>ad", group = "Desc" },
					{ "<leader>add", "<cmd>Leet desc toggle<cr>", desc = "Toggle" },
					{ "<leader>ads", "<cmd>Leet desc stats<cr>", desc = "Show stats" },
					{ "<leader>ai", "<cmd>Leet info<cr>", desc = "Info" },
					{ "<leader>al", "<cmd>Leet lang<cr>", desc = "Change Lang" },
					{ "<leader>am", "<cmd>Leet menu<cr>", desc = "Menu" },
					{ "<leader>ar", "<cmd>Leet reset<cr>", desc = "Reset" },
					{ "<leader>aR", "<cmd>Leet last_submit<cr>", desc = "Reset Last Submission" },
					{ "<leader>ax", "<cmd>Leet submit<cr>", desc = "Submit" },
					{ "<leader>ay", "<cmd>Leet yank<cr>", desc = "Yank" },
					{ "<leader>at", "<cmd>Leet run<cr>", desc = "Test" },
					{ "<leader>ao", "<cmd>Leet open<cr>", desc = "Open in Browser" },
					{ "<leader>a<tab>", "<cmd>Leet tabs<cr>", desc = "Tabs" },
					{ "<leader>aq", "<cmd>Leet exit<cr>", desc = "Exit" },
				},
			},
		},
	},
}
