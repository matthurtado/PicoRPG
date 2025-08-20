-- utility helpers

-- clamp a value between min and max
function SYS.util.clamp(val, min, max)
  return mid(min, val, max)
end

-- shallow copy of a table
function SYS.util.shallow_copy(t)
  local r = {}
  for k,v in pairs(t) do r[k]=v end
  return r
end

-- deep copy (good for cloning entities/spells)
function SYS.util.deepcopy(t)
  if type(t)~="table" then return t end
  local r={}
  for k,v in pairs(t) do
    r[SYS.util.deepcopy(k)] = SYS.util.deepcopy(v)
  end
  return r
end

-- chance helper: returns true with given probability (0..1)
function SYS.util.chance(p)
  return rnd(1) < p
end

-- check if list contains an element
function SYS.util.list_has(t, name)
  if not t then return false end
  for v in all(t) do if v==name then return true end end
  return false
end