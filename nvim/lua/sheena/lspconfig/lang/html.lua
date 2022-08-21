local M = {}
function M.custom_config()
  return {
    cmd = { "vscode-html-language-server", "--stdio" },
    configurationSection = {
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
    },
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
