local config = require('kitty.config')
local sessions = require('kitty.sessions')

local M = {}

function M.setup(opts)
  config.setup(opts)
  sessions.setup()
end

return M
