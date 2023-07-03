local M = {}

---@class KittyOptions
---@field command string
---@field workspaces table
local defaults = {
  session_dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"), -- directory where session files are saved
}

---@type KittyOptions
M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
