-- ui helpers (hud, menus, messages)

-- draw a simple text box
function SYS.ui.msgbox(text, x, y, w, h)
  rectfill(x, y, x+w, y+h, 0)
  rect(x, y, x+w, y+h, 7)
  print(text, x+2, y+2, 7)
end

-- draw a vertical menu
function SYS.ui.menu(options, cursor, x, y)
  for i,opt in ipairs(options) do
    local sel = (i==cursor)
    local col = sel and 11 or 6
    print((sel and "▶ " or "  ")..opt.label, x, y+(i-1)*10, col)
  end
end

-- hud strip at top
function SYS.ui.hud(hero)
  rectfill(0,0,127,10,1)
  print("lvl:"..hero.lvl.." hp:"..hero.hp.."/"..hero.max_hp.." g:"..hero.g,2,2,7)
  if STATE.debug_msg then
    print(STATE.debug_msg, 2, 118, 8)  -- bottom left, color 8 (red)
  end
  
end
