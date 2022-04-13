require('sheena')
function ConnectToHomestead()
  vim.g.homestead = "mysql://homestead:secret@192.168.56.15/" .. vim.fn.input('database? ')
end

function ConnectToFrontline()
  vim.g.frontline = "mysql://frontline:!jFr0ntLine2018%@frontlineapplive.cbpo01l5zn8p.ap-southeast-1.rds.amazonaws.com/" .. vim.fn.input('database? ')
end
