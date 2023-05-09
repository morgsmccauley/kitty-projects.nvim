local config = require('kitty.config')

local M = {}

function M.setup(opts)
  config.command = opts.command
  config.workspaces = opts.workspaces
end

return M
