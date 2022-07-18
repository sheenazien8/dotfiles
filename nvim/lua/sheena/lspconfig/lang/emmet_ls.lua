local M = {}
function M.custom_config()
  return {
    -- cmd = { 'emmet-ls', '--stdio' };
    cmd = {'ls_emmet', '--stdio'},
    filetypes = {
      'vue',
      'html',
      'css',
      'scss',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'sass',
    };
    settings = {
      html_filetypes = {'xml', 'html', 'blade'},
      css_filetypes = {'css', 'html', 'blade'},
    }
  }
end
return M


