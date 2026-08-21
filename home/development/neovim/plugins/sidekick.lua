return {
	"folke/sidekick.nvim",
	lazy = true,
	cmd = { "Sidekick" },
	keys = {
		{
			"<leader>ci",
			function()
				require("sidekick.cli").toggle({
					name = "codex",
					focus = true,
				})
			end,
			desc = "Toggle Codex popup",
			mode = { "n", "t" },
		},
	},
	opts = {
		-- Enable later only if Copilot NES is configured.
		nes = {
			enabled = false,
		},
		cli = {
			win = {
				layout = "float",
				float = {
					width = 0.9,
					height = 0.9,
					border = "rounded",
					title = " Codex ",
					title_pos = "center",
				},
				keys = {
					hide_ctrl_q = {
						"<C-q>",
						"hide",
						mode = "t",
						desc = "Hide Codex window",
					},
				},
			},
		},
	},
}
