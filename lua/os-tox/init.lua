local M = {}
local utils = require('os-tox.utils')
local create_cmd = vim.api.nvim_create_user_command

function M.open_definition(opts)
  local s = ""
  if opts.args ~= "" then
    s = opts.args
  else
    s = vim.fn.expand('<cWORD>')
  end
  local fpath = utils.get_test_file_path(s)

  vim.api.nvim_command('new ' .. fpath.path)
  if fpath.fun then
    vim.api.nvim_command('call search("def ' .. fpath.fun .. '")')
  elseif fpath.class then
    vim.api.nvim_command('call search("class ' .. fpath.class .. '")')
  end
end

function M.run_tox_test()
  print("Done M.run_tox_test()")
  local r = utils.get_test_path()
  print(r)
  utils.create_floating_term('tox -e py38 -- ' .. r)
  --utils.create_floating_term('ls')
end

function M.setup()
  create_cmd(
    'OsOpenDefinition',
    M.open_definition,
    {
      nargs = '?',
      desc = 'Open the class or method defined by the test path.'
    }
  )

  create_cmd(
    'OsRunTest',
    M.run_tox_test,
    {
      nargs = 0,
      desc = 'Run tox test'
    }
  )
end

return M
