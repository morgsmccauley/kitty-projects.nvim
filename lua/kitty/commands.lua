local Job = require('plenary.job')

local utils = require('kitty.utils')
local state = require('kitty.state')

local M = {}

function M.send_command(args)
  local raw_results = Job:new({
    command = 'kitty',
    args = utils.merge_tables(
      {
        '@',
        '--to=unix:/tmp/kitty-' .. vim.env.KITTY_PID,
      },
      args
    ),
  }):sync()

  if #raw_results > 0 then
    return vim.json.decode(table.concat(raw_results))
  end

  return {}
end

function M.list_windows()
  return M.send_command({ 'ls' })
end

function M.focus_tab(identifier)
  local match = nil

  if identifier.title then
    state.set({ previous_tab_title = state.get('current_tab_title') })
    state.set({ current_tab_title = identifier.title })

    match = 'title:' .. identifier.title
  elseif identifier.id then
    match = 'id:' .. identifier.id
  end

  return M.send_command({
    'focus-tab',
    '--match=' .. match
  })
end

function M.launch_tab(args)
  local optional_args = {}

  if args.tab_title then
    table.insert(optional_args, '--tab-title=' .. args.tab_title)
  end

  if args.window_title then
    table.insert(optional_args, '--window-title=' .. args.window_title)
  end

  if args.cwd then
    table.insert(optional_args, '--cwd=' .. args.cwd)
  end

  if args.cmd then
    table.insert(optional_args, args.cmd)
  end

  state.set({ previous_tab_title = state.get('current_tab_title') })
  state.set({ current_tab_title = args.tab_title })


  return M.send_command(utils.merge_tables(
    {
      'launch',
      '--type=tab'
    },
    optional_args
  ))
end

return M
