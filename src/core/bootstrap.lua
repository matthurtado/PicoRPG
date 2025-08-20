-- systems/bootstrap.lua  (FIRST include)
SYS = SYS or {}
STATE = STATE or {}
STATE.map_w = STATE.map_w or 128  -- tiles
STATE.map_h = STATE.map_h or 32   -- tiles (use 64 if you’re using shared map)

SYS.entities = {}
SYS.entities.hero = {}
SYS.entities.enemies = {}
SYS.entities.spells = {}
SYS.battle = {}
SYS.battle.damage = {}
SYS.input = SYS.input or {}
SYS.menu = {}
SYS.overworld = SYS.overworld or {}
SYS.ui = {}
SYS.util = {}