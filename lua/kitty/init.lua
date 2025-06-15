local config = require('kitty.config')
local sessions = require('kitty.sessions')

local M = {}

function M.setup(opts)
  config.setup(opts)
  sessions.setup()
  
  -- Create user commands
  vim.api.nvim_create_user_command('KittyProjects', function()
    M.projects()
  end, { desc = 'Open kitty projects picker' })
  
  vim.api.nvim_create_user_command('KittyProjectsRefresh', function()
    require('kitty.projects').refresh()
    vim.notify('kitty-projects: Cache refreshed')
  end, { desc = 'Refresh project cache' })
  
  vim.api.nvim_create_user_command('KittyProjectsCurrent', function()
    local current = require('kitty.projects').get_current_project()
    if current then
      vim.notify('Current project: ' .. current.name .. ' (' .. current.path .. ')')
    else
      vim.notify('No current project found')
    end
  end, { desc = 'Show current project info' })
end

function M.projects()
  if config.options.picker == 'snacks' then
    require('snacks._extensions.kitty').projects()
  else
    vim.cmd('Telescope kitty projects')
  end
end

-- Expose additional API functions
M.refresh = function()
  return require('kitty.projects').refresh()
end

M.get_current_project = function()
  return require('kitty.projects').get_current_project()
end

M.list = function()
  return require('kitty.projects').list()
end

return M
