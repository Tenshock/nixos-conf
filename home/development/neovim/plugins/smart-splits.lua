return {
	"mrjones2014/smart-splits.nvim",
	lazy = false,
	dependencies = {
		{
			"smart-splits-nvim/backend-kitty",
			main = "smart-splits-backend-kitty",
			opts = {},
		},
	},
	opts = {
		move = {
			at_edge = "stop",
		},
		mux = {
			backend = "smart-splits-backend-kitty",
		},
	},
	keys = {
		{
			"<C-h>",
			function()
				require("smart-splits").move_cursor_left()
			end,
			mode = { "n", "v" },
		},
		{
			"<C-j>",
			function()
				require("smart-splits").move_cursor_down()
			end,
			mode = { "n", "v" },
		},
		{
			"<C-k>",
			function()
				require("smart-splits").move_cursor_up()
			end,
			mode = { "n", "v" },
		},
		{
			"<C-l>",
			function()
				require("smart-splits").move_cursor_right()
			end,
			mode = { "n", "v" },
		},
	},
}
