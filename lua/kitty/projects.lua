local Job = require('plenary.job')

local config = require('kitty.config')
local utils = require('kitty.utils')

local M = {}

function M.list()
  local projects = {}

  for _, workspace in ipairs(config.workspaces) do
    if type(workspace) == 'table' then
      local dir = workspace[1]

      local results = Job:new({
        command = 'ls',
        args = { dir },
      }):sync()

      local full_paths = vim.tbl_map(function(basename)
        return dir .. '/' .. basename
      end, results)

      projects = utils.merge_tables(projects, full_paths)
    else
      table.insert(projects, workspace)
    end
  end

  return projects
end

return M
