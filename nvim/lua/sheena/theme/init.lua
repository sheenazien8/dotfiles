local function set(theme)
  print("init theme")
  require('sheena.theme.'..theme)
end

return set
