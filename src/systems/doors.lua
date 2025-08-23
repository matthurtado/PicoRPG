-- systems/doors.lua
-- Add door mappings by mutating the tables created in bootstrap.

-- Register your door tile(s) here:
STATE.doors.by_tile[113] = {tx=125, ty=005, room={x=119, y=002, w=10, h=4}} 
STATE.doors.by_tile[121] = {tx=008, ty=005}

-- Register NPCs to houses
SYS.npcs.init()
SYS.npcs.add({
  name="Old Man Seth",
  spr=6,       -- set to your NPC sprite index
  tx=120, ty=3, -- inside your room
  solid=true,
  text={
    "Welcome to my home!",
    "Press ❎ to page messages.",
    "Have you tried the Absorb spell?"
  }
})
