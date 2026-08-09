return {
	{
		"okuuva/auto-save.nvim",
		version = "^1.0.0",
		cmd = "ASToggle",
		event = { "BufLeave", "FocusLost" },
		opts = {
			trigger_events = {
				immediate_save = {},
				defer_save = { "BufLeave", "FocusLost" },
			},
			debounce_delay = 125,
		},
	},
}
