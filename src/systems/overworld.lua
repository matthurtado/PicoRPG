-- systems/overworld.lua

function SYS.overworld.init()
  STATE.map_w = STATE.map_w or 128 
  STATE.map_h = STATE.map_h or 32
  STATE.camx  = STATE.camx or 0
  STATE.camy  = STATE.camy or 0
  STATE.steps = STATE.steps or 0
  STATE.enc_cool = STATE.enc_cool or 0
  STATE.enc_rate = STATE.enc_rate or 0.08
  if STATE.hero then STATE.hero.anim_t = STATE.hero.anim_t or 0 end
end

-- helpers
-- door helpers ---------------------------------------------------------------
local function find_door_dest(tx, ty)
  -- 1) exact cell match
  local by_cell = STATE.doors and STATE.doors.by_cell
  if by_cell then
    local d = by_cell[tx..","..ty]
    if d then return d.tx, d.ty end
  end

  -- 2) by tile id
  local by_tile = STATE.doors and STATE.doors.by_tile
  if by_tile then
    local id = mget(tx,ty)
    local d = by_tile[id] or by_tile[tostr(id)] -- tolerate string-keyed maps
    if d then return d.tx, d.ty end
  end

  -- 3) fallback default (optional)
  local def = STATE.default_interior
  if def then return def.tx, def.ty end
  return nil
end


local function teleport_to_tile(tx, ty)
  local h=STATE.hero
  local px, py = tx*8, ty*8
  h.x, h.y, h.tx, h.ty = px, py, px, py
  h.moving=false
  -- center camera on hero
  STATE.camx = mid(0, h.x-64, STATE.map_w*8-128)
  STATE.camy = mid(0, h.y-64, STATE.map_h*8-128)
  -- brief cooldown so we don't roll encounters right away
  STATE.enc_cool = 10
end

local function is_blocked(px,py)
  local tx,ty=flr(px/8), flr(py/8)
  return fget(mget(tx,ty),0) -- Flag 0 = solid
end

local function is_safe(px, py)
  local tx, ty = flr(px/8), flr(py/8)
  local tile = mget(tx, ty)
  return not fget(tile, 1) -- Flag 1 = not safe
end

local function random_enemy()
  -- clone the enemy so battle can mutate it
  local list=STATE.enemies
  local pick=list[flr(rnd(#list))+1]
  if SYS.util and SYS.util.deepcopy then
    return SYS.util.deepcopy(pick)
  else
    local c={} for k,v in pairs(pick) do c[k]=v end
    return c
  end
end

-- encounter screen FX (flash -> blinds -> hold -> battle)
local function start_encounter_fx(enemy)
  STATE.enc_fx = { enemy=enemy, t=0, phase="flash" }
end

local function encounter_fx_update()
  local fx = STATE.enc_fx
  if not fx then return end
  fx.t += 1

  local FLASH = 12    -- frames of white flash
  local CLOSE = 24   -- frames to close blinds
  local HOLD  = 6    -- frames to hold black

  if fx.phase=="flash" then
    if fx.t >= FLASH then fx.phase="close"; fx.t=0 end
  elseif fx.phase=="close" then
    if fx.t >= CLOSE then fx.phase="hold"; fx.t=0 end
  elseif fx.phase=="hold" then
    if fx.t >= HOLD then
      local e = fx.enemy
      STATE.enc_fx = nil
      SYS.battle.start(e)
    end
  end
end

local function encounter_fx_draw()
  local fx = STATE.enc_fx
  if not fx then return end

  camera()  -- screen space
  clip()

  local FLASH = 12
  local CLOSE = 24

  if fx.phase=="flash" then
    local period = 6
    local on = 3
    if (fx.t % period) < on then rectfill(0,0,127,127,7) end
    return
  end

  -- optional faint darken while closing
  -- What is this horrible magic number?
  fillp(0b0011001100110011) rectfill(0,0,127,127,0) fillp()

  -- venetian blinds closing to black (alternating direction per band)
  local t = min(1, fx.t / CLOSE)
  for r=0,15 do -- 16 rows * 8px = 128px
    local y0 = r*8
    local w  = flr(128*t)
    if (r%2)==0 then
      rectfill(0, y0, w-1, y0+7, 0)
    else
      rectfill(128-w, y0, 127, y0+7, 0)
    end
  end
end

local function try_encounter()
  if STATE.enc_cool>0 then return end
  local h=STATE.hero
  local tx,ty=flr(h.x/8), flr(h.y/8)
  local id=mget(tx,ty)
  if fget(id,1) and rnd()<STATE.enc_rate then
    start_encounter_fx(random_enemy())
    return
  end
  STATE.enc_cool=5
end

-- update/draw
function SYS.overworld.update()
  local h=STATE.hero
  STATE.enc_cool = max(0, (STATE.enc_cool or 0)-1)

  -- if encounter FX is active, tick it and freeze movement
  if STATE.enc_fx then
    encounter_fx_update()
    return
  end

  -- start a new tile step only when aligned to grid
  if not h.moving and h.x%8==0 and h.y%8==0 then
    
    local dx,dy=0,0
    if SYS.input.left()  then dx=-1; h.dir=0 end
    if SYS.input.right() then dx= 1; h.dir=1 end
    if SYS.input.up()    then dy=-1; h.dir=2 end
    if SYS.input.down()  then dy= 1; h.dir=3 end

    if dx~=0 or dy~=0 then
      local nx=h.x+dx*8
      local ny=h.y+dy*8
      if not is_blocked(nx,ny) then
        h.moving=true
        h.dx=dx*(h.spd or 1)
        h.dy=dy*(h.spd or 1)
        h.tx=nx
        h.ty=ny
      end
    end
  end

  if h.moving then
  h.x += h.dx
  h.y += h.dy
  if (h.dx>0 and h.x>=h.tx) or (h.dx<0 and h.x<=h.tx) then h.x=h.tx end
  if (h.dy>0 and h.y>=h.ty) or (h.dy<0 and h.y<=h.ty) then h.y=h.ty end
  if h.x==h.tx and h.y==h.ty then
    h.moving=false
    STATE.steps += 1

    -- we just landed on a tile: compute tile coords/id once
    local tx,ty = flr(h.x/8), flr(h.y/8)
    local id = mget(tx,ty)

    -- door check first
    if fget(id,2) then
      local dx,dy = find_door_dest(tx,ty)
      
      if dx then
        teleport_to_tile(dx,dy)
        return -- stop here this frame (skip encounter roll)
      end
    else
      -- optional: clear door debug when not on a door
      -- STATE.debug_msg = nil
    end

    -- only roll encounters on tiles marked "not safe" (flag 1 set)
    if not is_safe(h.x, h.y) then
      try_encounter()
    end
  end
end
  -- walk animation clock
  h.anim_t = h.anim_t or 0
  if h.moving then
    h.anim_t = (h.anim_t + 1) % 8 -- spd=1 -> 8 frames/tile; flip every 4
  else
    h.anim_t = 0
  end

  -- keep camera on hero
  STATE.camx = mid(0, h.x-64, STATE.map_w*8-128)
  STATE.camy = mid(0, h.y-64, STATE.map_h*8-128)
end

function SYS.overworld.draw()
  local camx,camy=flr(STATE.camx or 0), flr(STATE.camy or 0)
  camera(camx, camy)

  -- map
  local mx,my=flr(camx/8), flr(camy/8)
  map(mx, my, mx*8, my*8, 17, 17)

  -- hero walking animation (left uses flipped right)
  local h = STATE.hero
  local frames_right = {4,5}
  local frames_up    = {2,3}
  local frames_down  = {0,1}

  local anim
  if h.dir == 2 then
    anim = frames_up
  elseif h.dir == 3 then
    anim = frames_down
  else
    anim = frames_right -- 0=left,1=right (flip left)
  end

  local idx = 1
  if h.moving then
    idx = 1 + (flr(h.anim_t/4) % 2)
  end

  local flip_x = (h.dir == 0)
  spr(anim[idx], h.x, h.y, 1, 1, flip_x)

  -- HUD, then overlay the encounter FX last so it covers everything
  camera()
  if SYS.ui and SYS.ui.hud then SYS.ui.hud(STATE.hero) end
  encounter_fx_draw()
end
