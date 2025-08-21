function SYS.entities.enemies.init()
    STATE.enemies = {
        {
            name = "slime",
            spr = 16,
            w = 1,
            h = 1,
            hp = 8,
            atk = 3,
            def = 1,
            xp = 2,
            g = 3,
            spell = STATE.spells.slimeball,
            ai = { cast_chance = 0.20 },
            weaknesses = { STATE.spells.lightning.name },
            resistances = { STATE.spells.slimeball.name }
        },
        {
            name = "dracky",
            spr = 17,
            w = 1,
            h = 1,
            hp = 12,
            atk = 4,
            def = 2,
            xp = 4,
            g = 6,
            spell = STATE.spells.lightning,
            ai = { cast_chance = 0.15 },
            weaknesses = { STATE.spells.slimeball.name },
            resistances = { STATE.spells.lightning.name }
        },
    }
end
