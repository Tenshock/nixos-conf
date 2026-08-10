return {
	"folke/snacks.nvim",
	opts = {
		dashboard = {
			preset = {
				pick = function(cmd, opts)
					return LazyVim.pick(cmd, opts)()
				end,
				header = [[
 ███████╗██╗██████╗ ███████╗████████╗       ██████╗ ████████╗███████╗███╗   ███╗   
 ██╔════╝██║██╔══██╗██╔════╝╚══██╔══╝       ██╔══██╗╚══██╔══╝██╔════╝████╗ ████║   
 █████╗  ██║██████╔╝███████╗   ██║          ██████╔╝   ██║   █████╗  ██╔████╔██║   
 ██╔══╝  ██║██╔══██╗╚════██║   ██║          ██╔══██╗   ██║   ██╔══╝  ██║╚██╔╝██║   
 ██║     ██║██║  ██║███████║   ██║   ▄█╗    ██║  ██║   ██║   ██║     ██║ ╚═╝ ██║██╗
 ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝     ╚═╝╚═╝
]],
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
					{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "e", desc = "Leet", action = ":Leet" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
		explorer = {
			enabled = false,
		},
		image = {},
		picker = {
			sources = {
				files = { hidden = true },
				explorer = { hidden = true },
				grep = { hidden = true },
				grep_word = { hidden = true },
				grep_buffers = { hidden = true },
			},
		},
		statuscolumn = {
			enabled = true,
		},
	},
}
-- http://patorjk.com/software/taag -> ANSI Shadow

--        ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
--        ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
--        ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
--        ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
--        ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
--        ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝

--         ███████╗██╗██████╗ ███████╗████████╗       ██████╗ ████████╗███████╗███╗   ███╗
--         ██╔════╝██║██╔══██╗██╔════╝╚══██╔══╝       ██╔══██╗╚══██╔══╝██╔════╝████╗ ████║
--         █████╗  ██║██████╔╝███████╗   ██║          ██████╔╝   ██║   █████╗  ██╔████╔██║
--         ██╔══╝  ██║██╔══██╗╚════██║   ██║          ██╔══██╗   ██║   ██╔══╝  ██║╚██╔╝██║
--         ██║     ██║██║  ██║███████║   ██║   ▄█╗    ██║  ██║   ██║   ██║     ██║ ╚═╝ ██║██╗
--         ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝     ╚═╝╚═╝

--    ▄ ██╗▄
--     ████╗
--    ▀╚██╔▀
--      ╚═╝
