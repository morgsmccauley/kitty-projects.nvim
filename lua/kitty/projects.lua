local Job = require('plenary.job')

local commands = require('kitty.commands')
local config = require('kitty.config')
local utils = require('kitty.utils')

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
          end)

          local tmp = vim.tbl_extend(
            'force',
            {
              basename = basename,
              path = dir .. '/' .. basename,
            },
            tab ~= nil and tab or {}
          )
          return tmp
        end,
        sub_directories
      )


      all_projects = utils.merge_tables(all_projects, projects)
    else
      local basename = vim.fn.fnamemodify(workspace, ':t')

      local tab = utils.find_table_entry(tabs, function(entry)
        return entry.title == basename
      end)

      table.insert(all_projects, vim.tbl_extend(
        'force',
        {
          basename = basename,
          path = workspace,
        },
        tab ~= nil and tab or {}
      ))
    end
  end

  return all_projects
end

return M
