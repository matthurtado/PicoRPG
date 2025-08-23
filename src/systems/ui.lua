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
-- simple message pager usable from overworld, battle, etc.
function SYS.ui.say(lines, on_end)
  STATE.msg = {
    lines = type(lines)=="table" and lines or {lines},
    i = 1,
    on_end = on_end
  }
end

function SYS.ui.update_msg()
  local m = STATE.msg
  if not m then return false end
  if SYS.input.confirm() then
    m.i += 1
    if m.i > #m.lines then
      local cb = m.on_end
      STATE.msg = nil
      if cb then cb() end
    end
  end
  return true -- message is active, caller should early-return
end

function SYS.ui.draw_msg()
  local m = STATE.msg
  if not m then return end
  camera()      -- (0,0)
  clip()        -- clear any world clip
  pal() palt()  -- reset palette / transparency
  fillp()       -- clear any dither/pattern

  local box_y = 100
  rectfill(0, box_y, 127, 127, 1)  -- dark blue box
  rect(0, box_y, 127, 127, 0)      -- border
  print(m.lines[m.i] or "", 6, box_y+6, 7)
end
