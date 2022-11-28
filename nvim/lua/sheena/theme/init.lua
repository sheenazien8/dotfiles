local M = {}

M.setup = function (config)
  require("sheena.theme." .. config.theme)
end

return M
