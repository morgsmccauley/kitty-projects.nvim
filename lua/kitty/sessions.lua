local Config = require('kitty.config')

local M = {}

M.session_loaded = false;

function M.get_current()
  local name = vim.fn.getcwd():gsub('/', '__')
  return Config.options.session_dir .. name .. '.vim'
end

function M.setup()
  vim.fn.mkdir(Config.options.session_dir, 'p')
  M.start()
end

function M.start()
  local group = vim.api.nvim_create_augroup('kitty', { clear = true })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = M.save,
  })

  vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    group = group,
    callback = function()
      -- wait for vim setup to complete before loading the session
      -- without waiting, the buffers is loaded without a filetype
      vim.schedule(M.load)
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufEnter ' }, {
    group = group,
    callback = function()
      if not M.session_loaded then
        return
      end

      M.save()
    end,
  })
end

function M.save()
  local tmp = vim.o.sessionoptions
  vim.o.sessionoptions = table.concat(Config.options.session_opts, ',')
  vim.cmd('mksession! ' .. vim.fn.fnameescape(M.get_current()))
  vim.o.sessionoptions = tmp
end

function M.load()
  local sfile = M.get_current()
  if sfile and vim.fn.filereadable(sfile) ~= 0 then
    vim.cmd('silent! source ' .. vim.fn.fnameescape(sfile))
    M.session_loaded = true
  end
end

return M
