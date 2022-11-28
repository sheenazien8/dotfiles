require('sheena')
function ConnectToHomestead()
  vim.g.homestead = "mysql://homestead:secret@192.168.56.56/" .. vim.fn.input('database? ')
end
