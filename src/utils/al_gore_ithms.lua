function SYS.battle.can_escape(hero, enemy)
    return rnd()<0.5
end

function SYS.battle.damage.physical(attacker, defender)
    return max(1, attacker.atk - defender.def + flr(rnd(3))-1)
end

function SYS.battle.damage.defend(dmg)
    return max(1, flr(dmg / 2))
end

function SYS.battle.damage.spell(spell, defender)
    local base_dmg = max(1, (spell and spell.pow or 0) + flr(rnd(3)) - defender.def)
    return SYS.battle.damage.spell_mult_vs_enemy(defender, spell.name, base_dmg)
end

function SYS.battle.damage.spell_mult_vs_enemy(enemy, spell_name, base_dmg)
  local m = 1.0
  if SYS.util.list_has(enemy.weaknesses,  spell_name) then m = m * 2.0 end
  if SYS.util.list_has(enemy.resistances, spell_name) then m = m * 0.5 end
  return max(1, flr(base_dmg * m)), m
end