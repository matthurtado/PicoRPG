SYS.spells = {}

function SYS.spells.init()
  STATE.hero.spells = { {name="absorb", mp=2, kind="absorb"} }
  STATE.hero.absorb_chance = 0.5
end

function SYS.spells.has(name)
  for s in all(STATE.hero.spells) do if s.name==name then return true end end
end

function SYS.spells.learn(copy)
  if not copy or not copy.name or SYS.spells.has(copy.name) then return false end
  add(STATE.hero.spells, {name=copy.name, mp=copy.mp or 3, pow=copy.pow or 6, kind="attack"})
  return true
end
