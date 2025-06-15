local kitty_projects = require('kitty.projects')

local M = {}

function M.projects(opts)
  opts = opts or {}

  local projects = kitty_projects.list()

  -- Calculate max project name width for alignment
  local max_name_width = 0
  for _, project in ipairs(projects) do
    if #project.name > max_name_width then
      max_name_width = #project.name
    end
  end

  -- Format items for snacks picker
  local items = {}
  for _, project in ipairs(projects) do
    local indicator = ''
    if project.open and project.is_focused then
      indicator = '%a'
    elseif project.open and project.was_focused then
      indicator = '#a'
    elseif project.open then
      indicator = 'a'
    else
      indicator = ''
    end

    table.insert(items, {
      text = project.name,
      indicator = indicator,
      data = project,
      path = vim.fn.fnamemodify(project.path, ':~'),
      max_name_width = max_name_width
    })
  end

  require('snacks').picker.pick('kitty_projects', vim.tbl_deep_extend('force', {
    title = 'Kitty Projects',
    items = items,
    layout = { preset = "ivy", preview = false },
    format = function(item)
      -- Create fixed-width columns like Telescope's entry_display
      local indicator_col = string.format("%-2s", item.indicator)
      local name_col = string.format("%-" .. item.max_name_width .. "s", item.text)
      local path_col = item.path

      return {
        { indicator_col,   item.data.open and 'Normal' or 'Comment' },
        { " " .. name_col, item.data.open and 'Normal' or 'Comment' },
        { " " .. path_col, 'Comment' }
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
