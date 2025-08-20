-- input helpers (wrap btn / btnp)
SYS.input = {}

function SYS.input.left()  return btn(0) end
function SYS.input.right() return btn(1) end
function SYS.input.up()    return btn(2) end
function SYS.input.down()  return btn(3) end

function SYS.input.confirm() return btnp(4) end -- ❎
function SYS.input.cancel()  return btnp(5) end -- 🅾️

-- dpad navigation with wraparound
function SYS.input.menu_nav(cursor, max)
  if btnp(2) then cursor = (cursor-2)%max+1 end -- up
  if btnp(3) then cursor = (cursor)%max+1 end   -- down
  return cursor
end
