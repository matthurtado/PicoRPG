function SYS.entities.hero.init()
    STATE.hero = {
        x = 48,
        y = 48,
        dir = 2,
        moving = false,
        dx = 0,
        dy = 0,
        spd = 1,
        hp = 20,
        max_hp = 20,
        mp = 10,
        atk = 4,
        def = 2,
        lvl = 1,
        xp = 0,
        g = 0,
        spr = 1
    }

    STATE.hero.spells = { STATE.spells.absorb }
    STATE.hero.absorb_chance = 0.5
end

function SYS.entities.hero.has_spell(name)
    for s in all(STATE.hero.spells) do
        if s.name == name then
            return true
        end
    end
end

function SYS.entities.hero.learn_spell(copy)
    if not copy or not copy.name or SYS.entities.hero.has_spell(copy.name) then
        return false
    end

    add(STATE.hero.spells, { name = copy.name, mp = copy.mp or 3, pow = copy.pow or 6, kind = "attack" })
    return true
end
