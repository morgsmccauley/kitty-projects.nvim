local telescope = require('telescope')
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local utils = require('telescope.utils')

local config = require('telescope._extensions.config')

local kitty_projects = function(opts)
  opts = opts or {}

  local projects = {};
  for _, workspace in ipairs(config.workspaces) do
    if type(workspace) == 'table' then
      local dir = workspace[1]
      local results = utils.get_os_command_output({ 'ls', dir })
      local full_paths = vim.tbl_map(function(basename)
        return dir .. '/' .. basename
      end, results)
      projects = vim.tbl_extend('force', projects, full_paths)
    else
      table.insert(projects, workspace)
    end
  end

  pickers.new(opts, {
    prompt_title = 'Kitty Projects',
    finder = finders.new_table(
      {
        results = projects,
        entry_maker = function(line)
          local basename = vim.fn.fnamemodify(line, ':t')
          return {
            value = {
              basename = basename,
              absolute_path = line,
            },
            ordinal = basename,
            display = basename,
          }
        end,
      }
    ),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        local raw_results = utils.get_os_command_output({
          'kitty',
          '@',
          '--to=unix:/tmp/kitty-' .. vim.env.KITTY_PID,
          'ls'
        })
        local kitty_windows = vim.json.decode(table.concat(raw_results))

        local tab_exists = false
        for _, tab in ipairs(kitty_windows[1].tabs) do
          if tab.title == selection.value.basename then
            tab_exists = true
            break
          end
        end

        if tab_exists then
          vim.loop.spawn('kitty', {
            args = {
              '@',
              '--to=unix:/tmp/kitty-' .. vim.env.KITTY_PID,
              'focus-tab',
              '--match=title:' .. selection.value.basename,
            }
          })
          return true
        else
          vim.loop.spawn('kitty', {
            args = {
              '@',
              '--to=unix:/tmp/kitty-' .. vim.env.KITTY_PID,
              'launch',
              '--type=tab',
              '--tab-title=' .. selection.value.basename,
              '--window-title=' .. selection.value.basename,
              '--cwd=' .. selection.value.absolute_path,
              'nvim'
            }
          })
        end
      end)
      return true
    end,
  }):find()
end

return telescope.register_extension({
  setup = function(opts)
    config = opts
  end,
  exports = {
    projects = kitty_projects
  }
})
