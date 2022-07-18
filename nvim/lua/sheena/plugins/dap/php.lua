local dap = require('dap')

dap.adapters.php = {
  type = 'executable',
  command = 'node',
  args = { os.getenv("HOME") .. '/Documents/Code/apps/vscode-php-debug/out/phpDebug.js' }
}
dap.configurations.php = {
  {
    type = 'php',
    request = 'launch',
    name = 'Listen for Xdebug',
    port = 9003
  },
  {
    name = "Listen for XDebug on Homestead",
    type = "php",
    request = "launch",
    --[[ pathMappings = {
      "/home/vagrant/Code/tighten-app-homestead" = "/Users/jose/Code/tighten-app-homestead"
    }, ]]
    port = 9000
  }
}
