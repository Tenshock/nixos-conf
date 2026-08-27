return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				jsonls = {
					handlers = {
						["vscode/content"] = function(_, params)
							local uri = params[1]
							if type(uri) == "string" and vim.startswith(uri, "vscode://schemas/") then
								return "{}"
							end

							return nil,
								{
									code = vim.lsp.protocol.ErrorCodes.InvalidParams,
									message = "Unsupported schema URI: " .. vim.inspect(uri),
								}
						end,
					},
				},
			},
		},
	},
}
