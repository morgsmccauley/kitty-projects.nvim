local Job = require('plenary.job')

local M = {}

function M.merge_tables(table1, table2)
  for _, value in ipairs(table2) do
    table.insert(table1, value)
  end
  return table1
end

function M.find_table_entry(tbl, test_fn)
  local index = 0

  for i, value in ipairs(tbl) do
    if test_fn(value) then
      index = i
      break
    end
  end

  return tbl[index]
end

function M.list_sub_directories(parent_dir)
  return Job:new({
    command = 'find',
    args = {
      parent_dir,
      '-maxdepth', '1',
      '-mindepth', '1',
      '-type', 'd'
    },
  }):sync()
end

return M
