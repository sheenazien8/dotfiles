local M = {}
function M.custom_config()
  return {
    cmd = { 'ls_emmet', '--stdio' };
    filetypes = {
      'blade',
      'html',
      'css',
      'scss',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'haml',
      'xml',
      'xsl',
      'pug',
      'slim',
      'sass',
      'stylus',
      'less',
      'sss',
      'hbs',
      'handlebars',
    };
  }
end
return M


