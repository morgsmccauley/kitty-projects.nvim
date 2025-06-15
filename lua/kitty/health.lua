local M = {}

function M.check()
  vim.health.start("kitty-projects.nvim")
  
  -- Check if we're running in Kitty
  if not vim.env.KITTY_PID then
    vim.health.error("Not running in Kitty terminal", {
      "kitty-projects.nvim requires running Neovim inside Kitty terminal",
      "Install Kitty: https://sw.kovidgoyal.net/kitty/"
    })
    return
  end
  
  -- Check if remote control is enabled
  local Job = require('plenary.job')
  local result = Job:new({
    command = 'kitty',
    args = { '@', '--to=unix:/tmp/kitty-' .. vim.env.KITTY_PID, 'ls' },
  }):sync()
  
  if vim.v.shell_error ~= 0 then
    vim.health.error("Kitty remote control not enabled", {
      "Add 'allow_remote_control yes' to your kitty.conf",
      "Or start kitty with: kitty --listen-on=unix:/tmp/kitty"
    })
  else
    vim.health.ok("Kitty remote control is working")
  end
  
  -- Check project paths
  local config = require('kitty.config')
  if not config.options.project_paths or #config.options.project_paths == 0 then
    vim.health.warn("No project paths configured", {
      "Add project_paths to your setup() call"
    })
  else
    for _, path in ipairs(config.options.project_paths) do
      local dir = type(path) == 'table' and path[1] or path
      if vim.fn.isdirectory(dir) == 0 then
        vim.health.warn("Project path does not exist: " .. dir)
      else
        vim.health.ok("Project path exists: " .. dir)
      end
    end
  end
end

return M