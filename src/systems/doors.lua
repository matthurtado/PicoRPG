-- systems/doors.lua
-- Add door mappings by mutating the tables created in bootstrap.

STATE.doors = STATE.doors or {}
STATE.doors.by_cell = STATE.doors.by_cell or {}
STATE.doors.by_tile = STATE.doors.by_tile or {}

-- Register your door tile(s) here:
STATE.doors.by_tile[113] = {tx=125, ty=005}  -- door sprite #113 -> interior (96,20)
STATE.doors.by_tile[121] = {tx=008, ty=005}

-- examples for more doors:
-- STATE.doors.by_tile[114] = {tx=104, ty=18}
-- STATE.doors.by_tile[115] = {tx=88,  ty=22}
