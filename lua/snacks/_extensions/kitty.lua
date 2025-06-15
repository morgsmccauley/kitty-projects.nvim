local kitty_projects = require('kitty.projects')

local M = {}

function M.projects(opts)
  opts = opts or {}

  local projects = kitty_projects.list()

  -- Format items for snacks picker
  local items = {}
  for _, project in ipairs(projects) do
    local indicator = ''
    if project.open and project.is_focused then
      indicator = '%a '
    elseif project.open and project.was_focused then
      indicator = '#a '
    elseif project.open then
      indicator = 'a  '
    else
      indicator = '   '
    end

    table.insert(items, {
      text = indicator .. project.name,
      data = project,
      path = vim.fn.fnamemodify(project.path, ':~')
    })
  end

  require('snacks').picker.pick('kitty_projects', vim.tbl_deep_extend('force', {
    title = 'Kitty Projects',
    items = items,
    layout = { preset = "ivy", preview = false },
    format = function(item)
      return {
        { item.text,        item.data.open and 'Normal' or 'Comment' },
        { ' ' .. item.path, 'Comment' }
      }
    end,
    actions = {
      default = function(item)
        kitty_projects.switch(item.data)
      end,
      close = function(item)
        kitty_projects.close(item.data)
      end,
      restart = function(item)
        kitty_projects.restart(item.data)
      end
    },
    keys = {
      ['<C-x>'] = 'close',
      ['<C-r>'] = 'restart'
    }
  }, opts))
end

return M
