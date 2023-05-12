local telescope = require('telescope')
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local pickers = require 'telescope.pickers'
local entry_display = require('telescope.pickers.entry_display')
local finders = require 'telescope.finders'
local conf = require('telescope.config').values

local kitty_command = require('kitty.commands')
local kitty_projects = require('kitty.projects')
local state = require('kitty.state')

local list_kitty_projects = function(opts)
  opts = opts or {}

  local projects = kitty_projects.list()

  local max_width = 0
  for _, project in ipairs(projects) do
    if #project.name > max_width then
      max_width = #project.name
    end
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = 2 },
      { width = max_width },
      { remaining = true },
    },
  }

  pickers.new(opts, {
    prompt_title = 'Kitty Projects',
    finder = finders.new_table(
      {
        results = projects,
        entry_maker = function(project)
          local indicator = ''
          if project.is_focused then
            indicator = '%a'
          elseif project.was_focused then
            indicator = '#a'
          elseif project.open then
            indicator = 'a'
          end

          return {
            value = project,
            ordinal = project.name,
            display = function()
              return displayer({
                indicator,
                project.name,
                { project.path, 'TelescopeResultsComment' }
              })
            end
          }
        end,
      }
    ),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local project = selection.value

        kitty_projects.switch(project)
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
