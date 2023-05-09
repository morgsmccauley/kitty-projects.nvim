local Job = require('plenary.job')

local M = {}

local merge = function(table1, table2)
  for _, value in ipairs(table2) do
    table.insert(table1, value)
  end
  return table1
end

function M.send_command(args)
  local raw_results = nil

  Job:new({
    command = 'kitty',
    args = merge(
      {
        '@',
        '--to=unix:/tmp/kitty-' .. vim.env.KITTY_PID,
      },
      args
    ),
    on_exit = function(j)
      raw_results = j:result()
    end

  }):sync()

  if #raw_results > 0 then
    return vim.json.decode(table.concat(raw_results))
  end

  return {}
end

function M.list_windows()
  return M.send_command({ 'ls' })
end

function M.focus_tab(identifier)
  local match = nil

  if identifier.title then
    match = 'title:' .. identifier.title
  elseif identifier.id then
    match = 'id:' .. identifier.id
  end

  return M.send_command({
    'focus-tab',
    '--match=' .. match
  })
end

return M
