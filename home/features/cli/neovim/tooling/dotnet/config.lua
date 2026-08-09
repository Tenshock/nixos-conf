local function find_closest_file(filename)
	local path = vim.fn.expand("%:p")
	local dir = vim.fn.fnamemodify(path, ":h")
	local stop_point = vim.fn.expand("$HOME") .. "/repo"

	while dir and dir ~= stop_point do
		local match = vim.fn.globpath(dir, filename, false, true)
		if #match > 0 then
			return match[1]
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end
	return nil
end

local projects_being_built = {}
local built_projects = {}

local function build_dotnet_project()
	local sln_file = find_closest_file("*.sln")
	local csproj_file = find_closest_file("*.csproj")
	local target = sln_file or csproj_file

	if target and not built_projects[target] and not projects_being_built[target] then
		projects_being_built[target] = true

		local target_name = vim.fn.fnamemodify(target, ":t")
		local build_type = sln_file and "solution" or "project"
		vim.notify("🚀 Building .NET " .. build_type .. "\n   " .. target_name, vim.log.levels.INFO)

		vim.fn.jobstart("dotnet build " .. vim.fn.shellescape(target), {
			on_exit = function(_, code)
				projects_being_built[target] = false

				if code == 0 then
					vim.notify("✅ .NET build successful:\n   " .. target_name, vim.log.levels.INFO)
					built_projects[target] = true

					vim.api.nvim_create_autocmd("LspAttach", {
						once = true,
						callback = function()
							vim.schedule(function()
								vim.cmd("LspRestart")
								vim.notify("🔄 LSP Restarted after Initialization!", vim.log.levels.INFO)
							end)
						end,
					})
				else
					vim.notify("❌ .NET build failed:\n   " .. target_name, vim.log.levels.ERROR)
				end
			end,
			stdout_buffered = true,
			stderr_buffered = true,
		})
	end
end

return {
	{
		"stevearc/conform.nvim",
		init = function()
			vim.api.nvim_create_autocmd("BufReadPost", {
				pattern = { "*.cs", "*.csproj", "*.sln" },
				callback = build_dotnet_project,
			})
		end,
		opts = {
			formatters = {
				csharpier = {
					command = "csharpier",
				},
			},
		},
	},
}
