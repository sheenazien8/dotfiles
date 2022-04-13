require('sheena')
function ConnectToHomestead()
  vim.g.homestead = "mysql://homestead:secret@192.168.56.15/" .. vim.fn.input('database? ')
end
