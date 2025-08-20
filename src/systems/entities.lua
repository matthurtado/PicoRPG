SYS.entities = {}

function SYS.entities.init()
  STATE.hero = {
    x=48,y=48, dir=2, moving=false, dx=0,dy=0, spd=1,
    hp=20,max_hp=20, mp=5, atk=4, def=2, lvl=1, xp=0, g=0,
    spr=1
  }

  STATE.enemies = {
    {name="slime",  spr=16, w=1,h=1, hp=8, atk=3, def=1, xp=2, g=3,
     spell={name="slimeball", pow=5, mp=3}, ai={cast_chance=0.20}, weaknesses={"lightning"}, resistances={"slimeball"}},
    {name="dracky", spr=17, w=2,h=2, hp=12,atk=4, def=2, xp=4, g=6,
     spell={name="lightning", pow=7, mp=4}, ai={cast_chance=0.15}, weaknesses={"slimeball"}, resistances={"lightning"}},
  }
end
