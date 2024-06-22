local M = {}
local utils = require("os-tox.utils")
local create_cmd = vim.api.nvim_create_user_command
-- TODO: replace python version with `basepython`.
local py = "py310"

function M.open_definition(opts)
	local s = ""
	if opts.args ~= "" then
		s = opts.args
	else
		s = vim.fn.expand("<cWORD>")
	end
	local fpath = utils.get_test_file_path(s)

	vim.api.nvim_command("new " .. fpath.path)
	if fpath.fun then
		vim.api.nvim_command('call search("def ' .. fpath.fun .. '")')
	elseif fpath.class then
		vim.api.nvim_command('call search("class ' .. fpath.class .. '")')
	end
end

function M.run_tox_test()
	M.run_tox("test")
end

function M.run_tox_debug()
	M.run_tox("debug")
end

function M.run_tox(args)
	local r = utils.get_test_path()
	local cmd = ""
	-- utils.my_pretty_print(r)

	if args == "test" then
		cmd = "tox -e " .. py .. " -- " .. r
	elseif args == "debug" then
		cmd = "tox -e debug -- " .. r
	end
	print(cmd)
	utils.create_floating_term(cmd)
end

function M.setup()
	create_cmd("OsOpenDefinition", M.open_definition, {
		nargs = "?",
		desc = "Open the class or method defined by the test path.",
	})

	create_cmd("OsRunTest", M.run_tox_test, {
		nargs = 0,
		desc = "Run tox test",
	})

	create_cmd("OsRunDebug", M.run_tox_debug, {
		nargs = 0,
		desc = "Run tox debug",
	})
end

return M
