-- systems/overworld.lua

function SYS.overworld.init()
  STATE.map_w = STATE.map_w or 128 
  STATE.map_h = STATE.map_h or 32
  STATE.camx  = STATE.camx or 0
  STATE.camy  = STATE.camy or 0
  STATE.steps = STATE.steps or 0
  STATE.enc_cool = STATE.enc_cool or 0
  STATE.enc_rate = STATE.enc_rate or 0.08
  -- EDIT: ensure hero has an animation timer (safe if hero is created elsewhere)
  if STATE.hero then STATE.hero.anim_t = STATE.hero.anim_t or 0 end
end

-- helpers
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
    -- shallow fallback (still ok for basic usage)
    local c={} for k,v in pairs(pick) do c[k]=v end
    return c
  end
end

local function try_encounter()
  if STATE.enc_cool>0 then return end
  local h=STATE.hero
  local tx,ty=flr(h.x/8), flr(h.y/8)
  local id=mget(tx,ty)
  if fget(id,1) and rnd()<STATE.enc_rate then
    SYS.battle.start(random_enemy())
    return
  end
  STATE.enc_cool=5
end

-- update/draw
function SYS.overworld.update()
  local h=STATE.hero
  STATE.enc_cool = max(0, (STATE.enc_cool or 0)-1)

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
      -- only roll encounters on tiles marked "not safe" (flag 1 set)
      if not is_safe(h.x, h.y) then
        try_encounter()
      end
    end
  end

  -- EDIT: advance / reset walk animation clock
  h.anim_t = h.anim_t or 0
  if h.moving then
    h.anim_t = (h.anim_t + 1) % 8
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

  -- draw enough map to cover screen
  local mx,my=flr(camx/8), flr(camy/8)
  map(mx, my, mx*8, my*8, 17, 17)

  -- EDIT: walking animation (no separate left set; flip from right)
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
    -- dir 0=left,1=right -> both use right set; left will flip
    anim = frames_right
  end

  local idx = 1
  if h.moving then
    idx = 1 + (flr(h.anim_t/4) % 2) -- 1 or 2
  end

  local flip_x = (h.dir == 0) -- flip when facing left
  spr(anim[idx], h.x, h.y, 1, 1, flip_x)

  camera()
  if SYS.ui and SYS.ui.hud then SYS.ui.hud(STATE.hero) end
end
