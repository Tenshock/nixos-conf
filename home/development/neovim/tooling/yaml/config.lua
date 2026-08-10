return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				yamlls = {
					filetypes = {
						"helm",
					},
					settings = {
						yaml = {
							schemas = {
								["https://gitlab.com/gitlab-org/gitlab-foss/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
									".gitlab-ci.yml",
									".gitlab-ci.yaml",
									".gitlab/*.yml",
									".gitlab/*.yaml",
									".gitlab/ci/*.yml",
									".gitlab/ci/*.yaml",
								},
							},
							customTags = {
								"!Ref scalar",
								"!Sub",
								"!GetAtt",
								"!GetAtt sequence",
								"!Join sequence",
								"!Select sequence",
								"!Split sequence",
								"!FindInMap sequence",
								"!ImportValue",
								"!If sequence",
								"!Equals sequence",
								"!And sequence",
								"!Or sequence",
								"!Not sequence",
								"!Base64",
								"!Cidr sequence",
								"!GetAZs",
								"!reference sequence",
								"!stack_output scalar",
							},
						},
					},
				},
			},
		},
	},
}
