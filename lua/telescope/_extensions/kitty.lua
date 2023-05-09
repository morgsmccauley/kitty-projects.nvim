local telescope = require('telescope')
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values

local kitty_command = require('kitty.commands')
local kitty_projects = require('kitty.projects')

local list_kitty_projects = function(opts)
  opts = opts or {}

  pickers.new(opts, {
    prompt_title = 'Kitty Projects',
    finder = finders.new_table(
      {
        results = kitty_projects.list(),
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

        local kitty_windows = kitty_command.list_windows()

        local tab_exists = false
        for _, tab in ipairs(kitty_windows[1].tabs) do
          if tab.title == selection.value.basename then
            tab_exists = true
            break
          end
        end

        if tab_exists then
          kitty_command.focus_tab({ title = selection.value.basename })
        else
          kitty_command.launch_tab({
            tab_title = selection.value.basename,
            window_title = selection.value.basename,
            cwd = selection.value.absolute_path,
            -- cmd = config.command
          })
        end
      end)

      return true
    end,
  }):find()
end

return telescope.register_extension({
  exports = {
    projects = list_kitty_projects
  }
})
