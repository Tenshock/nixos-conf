return {
	"nvim-neo-tree/neo-tree.nvim",
	keys = {
		{
			"<leader>ge",
			function()
				require("neo-tree.command").execute({ source = "git_status", position = "float", toggle = true })
			end,
			desc = "Git Explorer",
		},
		{
			"<leader>be",
			function()
				require("neo-tree.command").execute({ source = "buffers", position = "float", toggle = true })
			end,
			desc = "Buffer Explorer",
		},
	},
	opts = {
		filesystem = {
			filtered_items = {
				visible = true,
			},
		},
		default_component_configs = {
			git_status = {
				symbols = {
					-- Change type
					added = "✚", -- or "✚", but this is redundant info if you use git_status_colors on the name
					modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
					deleted = "✖", -- this can only be used in the git_status source
					renamed = "󰁕", -- this can only be used in the git_status source
					-- Status type
					untracked = "",
					ignored = "",
					unstaged = "󰄱",
					staged = "",
					conflict = "",
				},
			},
		},
		window = {
			width = "30",
			mappings = {
				["gx"] = function(state)
					local node = state.tree:get_node()
					if node then
						vim.ui.open(node:get_id())
					end
				end,
				["p"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
			},
		},
	},
}
