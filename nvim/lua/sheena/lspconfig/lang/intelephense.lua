local util = require('lspconfig.util')
-- local server_name = "intelephense"
local bin_name = "intelephense"

local M = {}
function M.custom_config()
  return {
    cmd = {bin_name, "--stdio"};
    filetypes = {"php"};
    root_dir = function (pattern)
      local cwd  = vim.loop.cwd();
      local root = util.root_pattern("composer.json", ".git")(pattern);

      -- prefer cwd if root is a descendant
      return util.path.is_descendant(cwd, root) and cwd or root;
    end;
    init_options =  {
      licenceKey = "000CKL0DIXLFA4U"
    },
    settings = {
      intelephense = {
	files = {
	  maxSize = 1000000;
	};
      };
    }
  }
end
return M
