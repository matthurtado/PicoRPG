function _init()
  -- global setup
  SYS.util = SYS.util or {} -- in case util defines helpers
  -- game state
  STATE.gamestate = "menu"
  SYS.entities.spells.init()
  SYS.entities.hero.init()  -- spells/hero/enemies data
  SYS.entities.enemies.init()
  SYS.menu.init()
end

function _update()
  if STATE.gamestate=="menu" then
    SYS.menu.update()
  elseif STATE.gamestate=="howto" then
    SYS.menu.update_howto()
  elseif STATE.gamestate=="overworld" then
    SYS.overworld.update()
  elseif STATE.gamestate=="battle" then
    SYS.battle.update()
  end
end

function _draw()
  -- reset palettes/transparency if you’ve been tweaking them
  pal(); for i=0,15 do palt(i,false) end; palt(0,true)

  if STATE.gamestate=="menu" then
    SYS.menu.draw()
  elseif STATE.gamestate=="howto" then
    SYS.menu.draw_howto()
  elseif STATE.gamestate=="overworld" then
    SYS.overworld.draw()
  elseif STATE.gamestate=="battle" then
    SYS.battle.draw()
  end
end
