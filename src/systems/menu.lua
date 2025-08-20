function SYS.menu.init()
  STATE.menu = {
    cursor=1,
    options = {
      {label="start game", action=function() SYS.overworld.init() STATE.gamestate="overworld" end},
      {label="how to play", action=function() STATE.gamestate="howto" end},
      {label="exit", action=function() extcmd("shutdown") end},
    }
  }
end

function SYS.menu.update()
  local m=STATE.menu
  if btnp(2) then m.cursor = (m.cursor-2)%#m.options+1 end -- up
  if btnp(3) then m.cursor = (m.cursor)%#m.options+1 end   -- down
  if btnp(4) then m.options[m.cursor].action() end         -- ❎
end

function SYS.menu.draw()
  cls(0)
  print("picorpg", 36, 18, 7)
  for i,opt in ipairs(STATE.menu.options) do
    local y = 52+(i-1)*12
    local sel = (i==STATE.menu.cursor)
    print((sel and "▶ " or "  ")..opt.label, 40, y, sel and 11 or 6)
  end
end
