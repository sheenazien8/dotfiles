local M = {}

function M.setup()
  require('sheena.lspconfig.lang')
end


return setmetatable({}, {
    __call = function()
        return M.setup()
    end,
})
