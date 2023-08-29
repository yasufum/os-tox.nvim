local M = {}
local create_user_command = vim.api.nvim_create_user_command

function M.hoge()
  print("hoge")
end

function M.setup()
  create_user_command('OsRun', M.hoge, { desc = 'Dummy function' })
end

return M
