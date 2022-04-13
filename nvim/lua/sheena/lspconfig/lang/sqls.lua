local M = {}
function M.custom_config()
  vim.cmd 'au! BufWrite *.sql SqlsExecuteQuery'
  return {
    cmd = {"/home/sheenazien/go/bin/sqls", "-config", "~/.config/sqls/config.yml"};
  }
end
return M

