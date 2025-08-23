SYS.npcs = SYS.npcs or {}

function SYS.npcs.init()
  STATE.npcs = STATE.npcs or {}
end

-- add an npc: {name, spr, tx, ty, solid=true, text={...}, on_talk=function(npc) ... end}
function SYS.npcs.add(n)
  n.solid = (n.solid ~= false)
  n.x, n.y = n.tx*8, n.ty*8
  add(STATE.npcs, n)
end

-- blocking check used by movement
function SYS.npcs.blocking_at(px, py)
  local tx,ty = flr(px/8), flr(py/8)
  for n in all(STATE.npcs) do
    if n.solid and n.tx==tx and n.ty==ty then return true end
  end
  return false
end

-- interact with npc in front of the hero
function SYS.npcs.try_interact()
  local h = STATE.hero
  local fx,fy = 0,0
  if h.dir==0 then fx=-8 elseif h.dir==1 then fx=8 elseif h.dir==2 then fy=-8 else fy=8 end
  local tx,ty = flr((h.x+fx)/8), flr((h.y+fy)/8)

  for n in all(STATE.npcs) do
    if n.tx==tx and n.ty==ty then
      if n.on_talk then
        n.on_talk(n)
      else
        local header = n.name and (n.name..": ") or ""
        SYS.ui.say(n.text or {header.."..."})
      end
      return true
    end
  end
  return false
end

-- draw only when visible (inside the room if one is active)
function SYS.npcs.draw()
  for n in all(STATE.npcs) do
    if not STATE.room or (n.tx>=STATE.room.x and n.tx<STATE.room.x+STATE.room.w
      and n.ty>=STATE.room.y and n.ty<STATE.room.y+STATE.room.h) then
      spr(n.spr, n.x, n.y)
    end
  end
end
