-- systems/input.lua
-- input helpers (wrap btn / btnp) with sane repeat for menus
SYS.input = SYS.input or {}

-- raw directions (held)
function SYS.input.left()  return btn(0) end
function SYS.input.right() return btn(1) end
function SYS.input.up()    return btn(2) end
function SYS.input.down()  return btn(3) end

-- confirm/cancel (edge-triggered)
function SYS.input.confirm() return btnp(4) end -- ❎
function SYS.input.cancel()  return btnp(5) end -- 🅾️

-- directional "pressed" with delayed repeat:
-- p = initial delay (frames), r = repeat rate (frames)
function SYS.input.nav_up(p, r)    return btnp(2, p or 12, r or 8) end
function SYS.input.nav_down(p, r)  return btnp(3, p or 12, r or 8) end
function SYS.input.nav_left(p, r)  return btnp(0, p or 12, r or 8) end
function SYS.input.nav_right(p, r) return btnp(1, p or 12, r or 8) end

-- menu helpers --------------------------------------------------------------

-- simple wraparound navigation (legacy)
function SYS.input.menu_nav(cursor, max)
  if SYS.input.nav_up()   then cursor = (cursor-2)%max+1 end
  if SYS.input.nav_down() then cursor = (cursor  )%max+1 end
  return cursor
end

-- returns (new_cursor, moved) so callers can ignore confirm on move frames
function SYS.input.menu_step(cursor, max, p, r)
  local moved=false
  if btnp(2, p or 12, r or 8) then cursor=(cursor-2)%max+1; moved=true end -- up
  if btnp(3, p or 12, r or 8) then cursor=(cursor  )%max+1; moved=true end -- down
  return cursor, moved
end
