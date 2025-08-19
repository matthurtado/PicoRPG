# tools/build_cart.py
from pathlib import Path
import re

BASE = Path("assets/base.p8")
SRC  = Path("src")
OUT  = Path("build/rpg.p8")

# Collect all lua sources
files = sorted(SRC.rglob("*.lua"), key=lambda p: str(p).lower())
merged = "\n".join(p.read_text(encoding="utf-8") for p in files)

# Read base cart
cart = BASE.read_text(encoding="utf-8")

# Replace __lua__ section (from __lua__ to before next __section__)
new_cart, n = re.subn(
    r"(?s)(__lua__\s*\n).*?(?=\n__\w+__|\Z)",
    r"\1" + merged + "\n",
    cart,
)

if n == 0:
    raise SystemExit("No __lua__ section found in base cart!")

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(new_cart, encoding="utf-8")

print(f"✅ Built {OUT}")
