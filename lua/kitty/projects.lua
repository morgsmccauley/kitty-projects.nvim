local commands = require('kitty.commands')
local config = require('kitty.config')
local utils = require('kitty.utils')
local Project = require('kitty.project')
local state = require('kitty.state')
local cache = require('kitty.cache')

local M = {}

local function list_project_paths()
  return cache.get_project_paths()
end

local function map_paths_to_projects(project_paths)
  local current_tab = commands.get_current_tab()
  local windows = current_tab and current_tab.windows or {}

  local previous_project_name = state.get('previous_project_name')

  local projects = vim.tbl_map(
    function(path)
      local basename = vim.fn.fnamemodify(path, ':t')

      local active_window = utils.find_table_entry(windows, function(entry)
        return entry.title == basename
      end)

      local project = Project:new({
        id = (active_window or {}).id,
        name = basename,
        path = path,
        is_focused = (active_window or {}).is_focused or false,
        was_focused = previous_project_name == basename,
        open = active_window ~= nil
      })

      return project
    end,
    project_paths
  )

  return projects
end

local function sort_projects_by_mru(projects)
  local current_project
  local previous_project
  local open_projects = {}
  local unopen_projects = {}

  for _, project in ipairs(projects) do
    if project.open then
      if project.is_focused then
        current_project = project
      elseif project.was_focused then
        previous_project = project
      else
        table.insert(open_projects, project)
      end
    else
      table.insert(unopen_projects, project)
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
  local projects = map_paths_to_projects(project_paths)
  local sorted_projects = sort_projects_by_mru(projects)

  return sorted_projects
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
  -- Do nothing if already focused on this project
  if project.is_focused then
    return
  end

  state.set({ previous_project_name = state.get('current_project_name') })
  state.set({ current_project_name = project.name })

  if project.open then
    commands.focus_window({ title = project.name })
  else
    M.launch(project)
  end
end

function M.restart(project)
  local old_window_id = project.open and project.id or nil

  M.launch(project)

  if old_window_id then
    vim.defer_fn(function()
      commands.close_window({ id = old_window_id })
    end, 100)
  end
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

function M.refresh()
  cache.invalidate()
  return M.list()
end

return M
