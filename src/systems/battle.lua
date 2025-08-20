SYS.battle = {}

local function say(b, lines, next_state)
  if type(lines)=="string" then lines={lines} end
  b.msgs = lines; b.msg_i=1; b.log=lines[1]; b.next_state=next_state or "menu"; b.state="msg"
end

function SYS.battle.start(enemy_tpl)
  local e = enemy_tpl
  if SYS.util and SYS.util.deepcopy then
    e = SYS.util.deepcopy(enemy_tpl)
  end
  e.charging = false

  STATE.battle = {
    enemy=e,
    state="menu",
    cursor=1,
    log="a "..e.name.." appears!",
    gave_rewards=false,
    msgs=nil, msg_i=0, next_state=nil,
    absorb_ready=false
  }
  STATE.gamestate = "battle"
end

local function spell_mult_vs_enemy(enemy, spell_name)
  local m = 1.0
  if SYS.util.list_has(enemy.weaknesses,  spell_name) then m = m * 2.0 end
  if SYS.util.list_has(enemy.resistances, spell_name) then m = m * 0.5 end
  return m
end

function SYS.battle.update()
  local b = STATE.battle
  if not b then return end
  local hero = STATE.hero

  -- ===== message paging =====
  if b.state=="msg" then
    if SYS.input.confirm() then
      b.msg_i += 1
      if b.msg_i > #b.msgs then
        b.state = b.next_state or "menu"
        b.msgs=nil b.msg_i=0 b.next_state=nil
      else
        b.log = b.msgs[b.msg_i]
      end
    end
    return
  end

  -- ===== main menu =====
  if b.state=="menu" then
    local moved=false
    -- read arrows directly to avoid helper mismatches
    if btnp(2) then b.cursor=(b.cursor-2)%3+1 moved=true end -- up
    if btnp(3) then b.cursor=(b.cursor  )%3+1 moved=true end -- down

    if (not moved) and SYS.input.confirm() then
      if b.cursor==1 then
        -- fight (basic attack)
        local dmg=max(1, hero.atk - b.enemy.def + flr(rnd(3))-1)
        b.enemy.hp -= dmg
        if b.enemy.hp<=0 then
          b.enemy.hp=0
          say(b, { "you hit for "..dmg.."!", "the "..b.enemy.name.." is defeated!" }, "victory")
        else
          say(b, "you hit for "..dmg.."!", "e_act")
        end

      elseif b.cursor==2 then
        -- open spell submenu
        b.state="spell_menu"
        b.spell_i = b.spell_i or 1

      else
        -- run
        if rnd()<0.5 then
          say(b, "you got away!", "escape")
        else
          say(b, "can't escape!", "e_act")
        end
      end
    end

  -- ===== spell menu =====
  elseif b.state=="spell_menu" then
    local n=#hero.spells
    if n==0 then
      say(b,"you know no spells.","menu")
      return
    end

    local moved=false
    b.spell_i = b.spell_i or 1
    if btnp(2) then b.spell_i=(b.spell_i-2)%n+1 moved=true end -- up
    if btnp(3) then b.spell_i=(b.spell_i  )%n+1 moved=true end -- down

    if SYS.input.cancel() then
      b.state="menu"
      return
    end

    if (not moved) and SYS.input.confirm() then
      local s=hero.spells[b.spell_i]
      local cost=s.mp or 0
      if hero.mp < cost then
        say(b,"not enough mp!","spell_menu")
        return
      end

      if s.kind=="absorb" then
        -- special: prime a learn check for next enemy cast if charging now
        hero.mp -= cost
        if b.enemy.charging and b.enemy.spell then
          b.absorb_ready = true
          say(b, "you focus to absorb!", "e_act")
        else
          say(b, "nothing to absorb...", "e_act")
        end
      else
        -- generic attack spell with weaknesses/resistances
        hero.mp -= cost
        local base = max(1, (s.pow or 0) + flr(rnd(3)) - b.enemy.def)
        local mult = spell_mult_vs_enemy(b.enemy, s.name) -- assumes your helper exists
        local dmg  = max(1, flr(base * mult))

        b.enemy.hp -= dmg

        local lines = { "you cast "..s.name.."!", "it dealt "..dmg.."!" }
        if mult > 1.0 then
          add(lines, "it's super effective!")
        elseif mult < 1.0 then
          add(lines, "resisted...")
        end

        if b.enemy.hp<=0 then
          b.enemy.hp=0
          add(lines, "the "..b.enemy.name.." is defeated!")
          say(b, lines, "victory")
        else
          say(b, lines, "e_act")
        end
      end
    end

  -- ===== enemy turn =====
  elseif b.state=="e_act" then
    local e=b.enemy

    if e.charging then
      -- spell goes off now
      e.charging=false
      local sp=e.spell
      local dmg=max(1, (sp and sp.pow or 0) + flr(rnd(3)) - hero.def)
      hero.hp-=dmg

      local msgs={ e.name.." casts "..(sp and sp.name or "a spell").."!", "it hits for "..dmg.."!" }

      -- resolve absorb learn (if primed on the previous hero turn)
      if b.absorb_ready and sp then
        b.absorb_ready=false
        local chance = hero.absorb_chance or 0.5
        if rnd()<chance then
          if SYS.spells.learn(sp) then
            add(msgs, "you learned "..sp.name.."!")
          else
            add(msgs, "you absorbed it, but learned nothing new.")
          end
        else
          add(msgs, "absorb failed...")
        end
      end

      if hero.hp<=0 then
        hero.hp=0
        say(b, msgs, "defeat")
      else
        say(b, msgs, "menu")
      end
      return
    end

    -- not charging: maybe start charging, else normal attack
    local will_cast = e.spell and e.ai and rnd() < (e.ai.cast_chance or 0)
    if will_cast then
      e.charging=true
      say(b, e.name.." is charging "..e.spell.name.."!", "menu")
      return
    end

    -- normal attack
    local dmg=max(1, e.atk - hero.def + flr(rnd(3))-1)
    hero.hp-=dmg
    if hero.hp<=0 then
      hero.hp=0
      say(b, e.name.." hits for "..dmg.."!", "defeat")
    else
      say(b, e.name.." hits for "..dmg.."!", "menu")
    end

  -- ===== end states =====
  elseif b.state=="victory" then
    if not b.gave_rewards then
      hero.xp += b.enemy.xp
      hero.g  += b.enemy.g
      b.gave_rewards=true
      if maybe_level_up then maybe_level_up() end
    end
    if not b.msgs then
      say(b, "victory! +"..b.enemy.xp.."xp +"..b.enemy.g.."g", "end_battle")
    end

  elseif b.state=="defeat" then
    if not b.msgs then
      say(b, "you were defeated...", "end_respawn")
    end

  elseif b.state=="escape" then
    if not b.msgs then
      say(b, "escaped!", "end_battle")
    end

  elseif b.state=="end_battle" then
    STATE.gamestate="overworld"
    STATE.enc_cool=10
    STATE.battle=nil

  elseif b.state=="end_respawn" then
    hero.hp=hero.max_hp
    hero.x,hero.y=64,64
    STATE.gamestate="overworld"
    STATE.enc_cool=10
    STATE.battle=nil
  end
end

function SYS.battle.draw()
  local b=STATE.battle
  if not b then return end
  local hero=STATE.hero
  local e=b.enemy

  camera()   -- screen space
  clip()

  -- background
  rectfill(0,0,127,63,12)    -- sky
  rectfill(0,64,127,95,3)    -- ground

  -- enemy (grounded on a baseline)
  if e then
    local w,h = e.w or 1, e.h or 1
    local baseline = 88
    local x = 64 - (w*8)/2
    local y = baseline - h*8
    if e.charging and draw_outline then
      draw_outline(e.spr, x, y, 8, 2, w, h)
    else
      spr(e.spr, x, y, w, h)
    end
    local sw = flr(w*8*0.9)
    local cx = x + (w*8)/2
    ovalfill(cx-sw/2, baseline, cx+sw/2, baseline+3, 0)
  end

  -- ===== top narration/message bar =====
  rectfill(0,0,127,12,1)
  rect(0,0,127,12,0)
  print(b.log or "", 2, 4, 7)

  -- quick stats under the bar
  print("hp:"..hero.hp.."/"..hero.max_hp.."  mp:"..hero.mp, 2, 14, 7)
  if e then
    local ehp = "enemy: "..e.name.."  hp:"..max(0,e.hp)
    print(ehp, 2, 22, 7)
  end

  -- ===== bottom command / spell menu box =====
  local box_y = 100
  rectfill(0, box_y, 127, 127, 1)
  rect(0, box_y, 127, 127, 0)

  if b.state=="menu" then
    if draw_list then
      draw_list({"fight","spell","run"}, b.cursor, 6, box_y+4)
    else
      -- minimal fallback if draw_list is not defined
      local opts={"fight","spell","run"}
      for i=1,3 do
        local yy = box_y+4+(i-1)*8
        local sel = (i==b.cursor)
        print((sel and "▶ " or "  ")..opts[i], 6, yy, sel and 7 or 6)
      end
    end

  elseif b.state=="spell_menu" then
    local names={}
    for i=1,#hero.spells do
      local s=hero.spells[i]
      names[i] = s.name.." ("..(s.mp or 0).."mp)"
    end
    if draw_list then
      draw_list(names, b.spell_i or 1, 6, box_y+4)
    else
      local cur=b.spell_i or 1
      for i=1,#names do
        local yy=box_y+4+(i-1)*8
        local sel=(i==cur)
        print((sel and "▶ " or "  ")..names[i], 6, yy, sel and 7 or 6)
      end
    end
  end
end
