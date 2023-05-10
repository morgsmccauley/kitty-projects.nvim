local M = {}

function M.merge_tables(table1, table2)
  for _, value in ipairs(table2) do
    table.insert(table1, value)
  end
  return table1
end

return M
