local Job = require('plenary.job')

local commands = require('kitty.commands')
local config = require('kitty.config')
local utils = require('kitty.utils')
local Project = require('kitty.project')
local state = require('kitty.state')

local M = {}

function M.list()
  local all_projects = {}

  local windows = commands.list_windows()
  local tabs = windows[1].tabs

  local previous_project_name = state.get('previous_project_name')

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
            is_focused = tab.is_focused,
            was_focused = previous_project_name == basename,
            open = tab.id
          })
        end,
        sub_directories
      )


      all_projects = utils.merge_tables(all_projects, projects)
    else
      local basename = vim.fn.fnamemodify(workspace, ':t')

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

function M.switch(project)
  state.set({ previous_project_name = state.get('current_project_name') })
  state.set({ current_project_name = project.name })

  if project.open then
    commands.focus_tab({ title = project.name })
  else
    commands.launch_tab({
      tab_title = project.name,
      window_title = project.name,
      cwd = project.path,
      -- cmd = config.command
    })
  end
end

return M
