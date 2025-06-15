local M = {}

---@class KittyOptions
---@field command string
---@field project_paths table
---@field picker string
---@field cache_ttl number
local defaults = {
  command = 'nvim', -- command used to start the Neovim instance
  session_dir = vim.fn.expand(vim.fn.stdpath('state') .. '/sessions/'),                           -- directory where session files are saved
  session_opts = { 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize', 'localoptions' }, -- sessionoptions used for saving
  picker = 'telescope', -- picker to use: 'telescope' or 'snacks'
  project_paths = {}, -- list of project paths
  cache_ttl = 30000, -- cache TTL in milliseconds
}

---@type KittyOptions
M.options = {}

local function validate_config(opts)
  if opts.picker and opts.picker ~= 'telescope' and opts.picker ~= 'snacks' then
    vim.notify('kitty-projects: Invalid picker "' .. opts.picker .. '". Must be "telescope" or "snacks"', vim.log.levels.WARN)
    opts.picker = 'telescope'
  end
  
  if opts.project_paths then
    for i, path in ipairs(opts.project_paths) do
      local dir = type(path) == 'table' and path[1] or path
      if type(dir) ~= 'string' then
        vim.notify('kitty-projects: Invalid project path at index ' .. i, vim.log.levels.WARN)
      elseif vim.fn.isdirectory(vim.fn.expand(dir)) == 0 then
        vim.notify('kitty-projects: Project path does not exist: ' .. dir, vim.log.levels.WARN)
      end
    end
  end
  
  if opts.cache_ttl and (type(opts.cache_ttl) ~= 'number' or opts.cache_ttl < 0) then
    vim.notify('kitty-projects: Invalid cache_ttl. Must be a positive number', vim.log.levels.WARN)
    opts.cache_ttl = defaults.cache_ttl
  end
end

function M.setup(opts)
  opts = opts or {}
  validate_config(opts)
  M.options = vim.tbl_deep_extend('force', {}, defaults, opts)
  
  -- Set cache TTL
  if opts.cache_ttl then
    require('kitty.cache').set_ttl(opts.cache_ttl)
  end
end

return M
