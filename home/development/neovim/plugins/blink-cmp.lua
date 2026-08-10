return {
	"saghen/blink.cmp",
	opts = function(_, opts)
		opts.sources = {
			transform_items = function(_, items)
				-- Remove the "Text" source from lsp autocomplete
				return vim.tbl_filter(function(item)
					return item.kind ~= vim.lsp.protocol.CompletionItemKind.Text
				end, items)
			end,
		}

		opts.fuzzy = {
			implementation = "prefer_rust_with_warning",
			prebuilt_binaries = {
				download = true,
			},
		}
	end,
}
