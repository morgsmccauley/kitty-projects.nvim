local M = {}

---@class KittyOptions
---@field command string
---@field workspaces table
local defaults = {
  session_dir = vim.fn.expand(vim.fn.stdpath('state') .. '/sessions/'),                           -- directory where session files are saved
  session_opts = { 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize', 'localoptions' }, -- sessionoptions used for saving
}

---@type KittyOptions
M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', {}, defaults, opts or {})
end

return M
