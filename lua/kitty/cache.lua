local M = {}

-- Cache for project paths with timestamps
local cache = {
  paths = nil,
  timestamp = 0,
  ttl = 30000 -- 30 seconds TTL
}

function M.get_project_paths()
  local now = vim.uv.now()
  
  -- Return cached paths if still valid
  if cache.paths and (now - cache.timestamp) < cache.ttl then
    return cache.paths
  end
  
  -- Cache miss - fetch new paths
  local config = require('kitty.config')
  local utils = require('kitty.utils')
  
  cache.paths = utils.list_all_sub_directories(config.options.project_paths)
  cache.timestamp = now
  
  return cache.paths
end

function M.invalidate()
  cache.paths = nil
  cache.timestamp = 0
end

function M.set_ttl(ttl_ms)
  cache.ttl = ttl_ms
end

return M