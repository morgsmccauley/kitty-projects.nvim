local Project = {}

function Project:new(args)
  return {
    name = args.name,
    path = args.path,
    is_focused = args.is_focused,
    open = args.open
  }
end

return Project
