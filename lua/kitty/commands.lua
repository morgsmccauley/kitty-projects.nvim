local Job = require('plenary.job')

local utils = require('kitty.utils')
local log = require('kitty.log')

local M = {}

function M.send_command(args)
  log.info('Running command: ', args)

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
    for _, arg in ipairs(vim.fn.split(args.cmd, ' ')) do
      table.insert(optional_args, arg)
    end
  end

  return M.send_command(utils.merge_tables(
    {
      'launch',
      '--type=tab'
    },
    optional_args
  ))
end

function M.launch_window(args)
  local optional_args = {}

  if args.title then
    table.insert(optional_args, '--title=' .. args.title)
  end

  if args.cwd then
    table.insert(optional_args, '--cwd=' .. args.cwd)
  end

  if args.env then
    for key, value in pairs(args.env) do
      table.insert(optional_args, '--env=' .. key .. '=' .. value)
    end
  end

  if args.cmd then
    for _, arg in ipairs(vim.fn.split(args.cmd, ' ')) do
      table.insert(optional_args, arg)
    end
  end

  return M.send_command(utils.merge_tables(
    {
      'launch',
      '--type=window'
    },
    optional_args
  ))
end

function M.focus_window(identifier)
  local match = nil

  if identifier.title then
    match = 'title:' .. identifier.title
  elseif identifier.id then
    match = 'id:' .. identifier.id
  end

  return M.send_command({
    'focus-window',
    '--match=' .. match
  })
end

function M.close_window(identifier)
  local match = nil

  if identifier.recent then
    match = 'recent:' .. identifier.recent
  elseif identifier.title then
    match = 'title:' .. identifier.title
  elseif identifier.id then
    match = 'id:' .. identifier.id
  end

  return M.send_command({
    'close-window',
    '--match=' .. match
  })
end

function M.close_tab(identifier)
  local match = nil

  if identifier.title then
    match = 'title:' .. identifier.title
  elseif identifier.id then
    match = 'id:' .. identifier.id
  end

  return M.send_command({
    'close-tab',
    '--match=' .. match
  })
end

return M
