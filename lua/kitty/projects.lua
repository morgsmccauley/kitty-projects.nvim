local Job = require('plenary.job')

local commands = require('kitty.commands')
local config = require('kitty.config')
local utils = require('kitty.utils')
local Project = require('kitty.project')
local state = require('kitty.state')

local M = {}

function M.list()
  local unopen_projects = {}

  local windows = commands.list_windows()
  local tabs = windows[1].tabs

  local previous_project_name = state.get('previous_project_name')

  local current_project
  local previous_project
  local open_projects = {}
  local remaining_projects = {}

  for _, workspace in ipairs(config.workspaces) do
    if type(workspace) == 'table' then
      local dir = workspace[1]

      local sub_directories = Job:new({
        command = 'ls',
        args = { dir },
      }):sync()

      remaining_projects = {}

      for _, basename in ipairs(sub_directories) do
        local tab = utils.find_table_entry(tabs, function(entry)
          return entry.title == basename
        end)

        if tab then
          if tab.is_focused then
            current_project = Project:new({
              name = basename,
              path = dir .. '/' .. basename,
              is_focused = true,
              was_focused = false,
              open = true
            })
          elseif previous_project_name == basename then
            previous_project = Project:new({
              name = basename,
              path = dir .. '/' .. basename,
              is_focused = false,
              was_focused = true,
              open = true
            })
          else
            table.insert(open_projects, Project:new({
              name = basename,
              path = dir .. '/' .. basename,
              is_focused = false,
              was_focused = false,
              open = true
            }))
          end
        else
          table.insert(remaining_projects, Project:new({
            name = basename,
            path = dir .. '/' .. basename,
            is_focused = false,
            was_focused = false,
            open = false
          }))
        end
      end

      unopen_projects = utils.merge_tables(remaining_projects, unopen_projects)
    else
      local basename = vim.fn.fnamemodify(workspace, ':t')

      local tab = utils.find_table_entry(tabs, function(entry)
        return entry.title == basename
      end)

      if tab then
        if tab.is_focused then
          current_project = Project:new({
            name = basename,
            path = workspace,
            is_focused = true,
            was_focused = false,
            open = true
          })
        elseif previous_project_name == basename then
          previous_project = Project:new({
            name = basename,
            path = workspace,
            is_focused = false,
            was_focused = true,
            open = true
          })
        else
          table.insert(open_projects, Project:new({
            name = basename,
            path = workspace,
            is_focused = false,
            was_focused = false,
            open = true
          }))
        end
      else
        table.insert(remaining_projects, Project:new({
          name = basename,
          path = workspace,
          is_focused = false,
          was_focused = false,
          open = false
        }))
      end
    end
  end

  local all_projects = {}

  if previous_project then
    table.insert(all_projects, previous_project)
  end

  if current_project then
    table.insert(all_projects, current_project)
  end

  if #open_projects > 0 then
    all_projects = utils.merge_tables(all_projects, open_projects)
  end

  return utils.merge_tables(all_projects, unopen_projects)
end

function M.close(project)
  if not project.open then
    return
  end

  commands.close_tab({ title = project.name })
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
      cmd = config.command
    })
  end
end

return M
