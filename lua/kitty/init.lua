local config = require('kitty.config')
local sessions = require('kitty.sessions')

local M = {}

function M.setup(opts)
  config.setup(opts)
  sessions.setup()
end

function M.projects()
  if config.options.picker == 'snacks' then
    require('snacks._extensions.kitty').projects()
  else
    vim.cmd('Telescope kitty projects')
  end
end

return M
