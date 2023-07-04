local Job = require('plenary.job')

local commands = require('kitty.commands')
local config = require('kitty.config')
local utils = require('kitty.utils')
local Project = require('kitty.project')
local state = require('kitty.state')

local M = {}

local function list_sub_directories(parent_dir)
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

local function list_project_paths()
  local paths = {}

  for _, path in ipairs(config.options.project_paths) do
    if type(path) == 'table' then
      local dir = path[1]

      local sub_directories = list_sub_directories(dir)

      utils.merge_tables(paths, sub_directories)
    else
      table.insert(paths, path)
    end
  end

  return paths
end

local function merge_kitty_windows(project_paths)
  local all_windows = commands.list_windows()
  local windows = all_windows[1].tabs[1].windows

  local previous_project_name = state.get('previous_project_name')

  local current_project
  local previous_project
  local open_projects = {}
  local unopen_projects = {}

  for _, path in ipairs(project_paths) do
    local basename = vim.fn.fnamemodify(path, ':t')

    local active_window = utils.find_table_entry(windows, function(entry)
      return entry.title == basename
    end)

    if active_window then
      if active_window.is_focused then
        current_project = Project:new({
          id = active_window.id,
          name = basename,
          path = path,
          is_focused = true,
          was_focused = false,
          open = true
        })
      elseif previous_project_name == basename then
        previous_project = Project:new({
          id = active_window.id,
          name = basename,
          path = path,
          is_focused = false,
          was_focused = true,
          open = true
        })
      else
        table.insert(open_projects, Project:new({
          id = active_window.id,
          name = basename,
          path = path,
          is_focused = false,
          was_focused = false,
          open = true
        }))
      end
    else
      table.insert(unopen_projects, Project:new({
        id = nil,
        name = basename,
        path = path,
        is_focused = false,
        was_focused = false,
        open = false
      }))
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

function M.list()
  local project_paths = list_project_paths()
  local kitty_projects = merge_kitty_windows(project_paths)

  return kitty_projects
end

function M.close(project)
  if not project.open then
    return
  end

  commands.close_window({ title = project.name })
end

function M.launch(project)
  commands.launch_window({
    title = project.name,
    cwd = project.path,
    cmd = config.options.command,
    env = {
      KITTY_PROJECTS = '1'
    }
  })
end

function M.switch(project)
  state.set({ previous_project_name = state.get('current_project_name') })
  state.set({ current_project_name = project.name })

  if project.open then
    commands.focus_window({ title = project.name })
  else
    M.launch(project)
  end
end

function M.restart(project)
  M.launch(project)

  vim.defer_fn(function()
    commands.close_window({ id = vim.env.KITTY_WINDOW_ID })
  end, 1000)
end

function M.get_current_project()
  local projects = M.list()
  local cwd = vim.fn.getcwd()

  local projects_with_cwd = vim.tbl_filter(
    function(project)
      return project.path == cwd
    end,
    projects
  )

  return projects_with_cwd[1]
end

return M
