local M = {}

function M.split_string(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end

  local t = {}
  local cnt = 0
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    cnt = cnt + 1
    table.insert(t, str)
  end
  return t, cnt
end

function M.create_floating_term(cmd)
  local columns = vim.api.nvim_get_option("columns")
  local lines = vim.api.nvim_get_option("lines")

  local width = math.ceil(columns * 0.7)
  local height = math.ceil(lines * 0.7)

  local start_col = math.ceil((columns - width) / 2)
  local start_line = math.ceil((lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    col = start_col,
    row = start_line,
    width = width,
    height = height,
    border = "single",
    style = "minimal"
  })

  -- vim.api.nvim_buf_set_option(buf, 'buftype', 'terminal')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'quickfix')
  vim.fn.termopen(cmd)

  local function on_exit(_, _)
    vim.api.nvim_win_close(win, true)
  end

  --local job_id = vim.api.nvim_buf_get_option(buf, 'terminal_job_id')
  --vim.fn.jobwait({ job_id })
  vim.api.nvim_buf_attach(buf, false, {
    on_detach = on_exit
  })
end

function M.pretty_print(obj)
  local tmp = {}
  if type(obj) == "table" then
    for i, j in pairs(obj) do
      table.insert(tmp, i .. ": " .. j)
    end
    print("{" .. table.concat(tmp, ", ") .. "}")
  else
    print(obj)
  end
end

function M.get_fn_name()
  -- TODO(yasufum): fix dummy
  local tnode = vim.treesitter.get_node_at_cursor(0)
  M.pretty_print(tnode)
  return "TestContoller", "test_create_without_name_and_description"
end

function M.get_test_path()
  local tpath = ""
  local full_path, _ = M.split_string(vim.fn.expand("%:p"), "/")
  local res = {}
  local idx = 0

  --  It's expected "${PROJ}/tests/unit" is found.
  for i = 1, #full_path do
    idx = (#full_path) - i

    if full_path[idx] == "tests" and full_path[idx + 1] == "unit" then
      break
    end

    if idx == 1 then
      break
    end
  end

  if idx > 1 then
    local t_root_idx = idx - 1
    local f_dir_idx = (#full_path) - 2

    for i = t_root_idx, f_dir_idx do
      print(i, full_path[i])
      table.insert(res, full_path[i])
    end
    local tmp, _ = M.split_string(vim.fn.expand("%:r"), "/")
    table.insert(res, tmp[#tmp])

    local cls, fn = M.get_fn_name()
    table.insert(res, cls)
    table.insert(res, fn)
    return table.concat(res, ".")
  end
end

function M.get_test_file_path(s)
  -- Confirm the number of args is 1.
  local _, sizeof_args = M.split_string(s, " ")
  if sizeof_args > 1 then
    error("'" .. s .. "'" .. " not a test path!")
  end

  local path_str = string.gsub(s, "%.", "/")
  path_str = string.gsub(path_str, "%(", "")
  path_str = string.gsub(path_str, "%)", "")
  local path, cnt = M.split_string(path_str, "/")

  -- Check if the given test path is valid.
  if cnt < 2 then
    error("'" .. path_str .. "'" .. " is a invalid test path.")
  end

  -- local ptn_cls = "Test" -- matches a class derived from UnitTest.
  local ptn_cls = "^[A-Z]" -- matches a class derived from UnitTest.
  local ptn_func = "^test_"
  local name_cls_fun = {}
  if string.match(path[#path - 1], ptn_cls) and string.match(path[#path], ptn_func) then
    table.insert(name_cls_fun, path[#path - 1])
    table.insert(name_cls_fun, path[#path])
    table.remove(path)
    table.remove(path)
  elseif string.match(path[#path], ptn_cls) then
    table.insert(name_cls_fun, path[#path])
    table.remove(path)
  end

  -- Find absolute path of a file of unittest to be opened, or directory
  -- possibly.
  -- To find the abs path, get path of current dir of opened file, then conbine
  -- it with `l:file_path` and check if it exists. If not found, cut the last
  -- element of this `l:opened_fdir` and try to check step by step until it's
  -- hit.
  local opened_fdir, cnt = M.split_string(vim.fn.expand("%:p"), "/")
  -- `expand("%:p")` returns empty list if no file opened.
  if cnt == 0 then
    opened_fdir, cnt = M.split_string(vim.fn.getcwd(), '/')
  end

  local f_ext = '.py'
  for i = 1, #opened_fdir do
    local l = {}
    for j = 1, #opened_fdir - i + 1 do
      table.insert(l, opened_fdir[j])
    end
    for k = 1, #path do
      table.insert(l, path[k])
    end

    local fpath = '/' .. table.concat(l, '/')
    if io.open(fpath .. f_ext) and vim.fn.filereadable(fpath .. f_ext) == 1 then
      return { path = fpath .. f_ext, class = name_cls_fun[1], fun = name_cls_fun[2] }
    elseif io.open(fpath) and vim.fn.isdirectory(fpath) == 1 then
      return { path = fpath, class = name_cls_fun[1], fun = name_cls_fun[2] }
    end
  end
end

return M
