return {
	"nvim-mini/mini.cursorword",
	version = false,
	config = function()
		require("mini.cursorword").setup({
			delay = 1,
		})
	end,
}
