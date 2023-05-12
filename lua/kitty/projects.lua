local Job = require('plenary.job')

local commands = require('kitty.commands')
local config = require('kitty.config')
local utils = require('kitty.utils')
local Project = require('kitty.project')

local M = {}

function M.list()
  local all_projects = {}

  local windows = commands.list_windows()
  local tabs = windows[1].tabs

  for _, workspace in ipairs(config.workspaces) do
    if type(workspace) == 'table' then
      local dir = workspace[1]

      local sub_directories = Job:new({
        command = 'ls',
        args = { dir },
      }):sync()

      local projects = vim.tbl_map(
        function(basename)
          local tab = utils.find_table_entry(tabs, function(entry)
            return entry.title == basename
          end) or {}

          return Project:new({
            name = basename,
            path = dir .. '/' .. basename,
            is_focused = tab.is_focused and true or false,
            open = tab.id
          })
        end,
        sub_directories
      )


      all_projects = utils.merge_tables(all_projects, projects)
    else
      local basename = vim.fn.fnamemodify(workspace, ':t')

      local tab = utils.find_table_entry(tabs, function(entry)
        return entry.title == basename
      end)

      table.insert(
        all_projects,
        Project:new({
          name = basename,
          path = workspace,
        })
      )
    end
  end

  return all_projects
end

return M
