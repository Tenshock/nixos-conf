return {
	{ "mason-org/mason.nvim", enabled = false },
	{ "mason-org/mason-lspconfig.nvim", enabled = false },
	{ "jay-babu/mason-nvim-dap.nvim", enabled = false },
	{
		"mfussenegger/nvim-dap",
		optional = true,
		opts = function()
			local dap = require("dap")

			for _, adapter_type in ipairs({ "node", "chrome", "msedge" }) do
				local adapter = dap.adapters["pwa-" .. adapter_type]
				if adapter and adapter.executable then
					adapter.executable.command = "js-debug"
				end
			end
		end,
	},
}
