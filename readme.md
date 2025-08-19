# PicoRPG

A Dragon Quest–inspired RPG built in [PICO-8](https://www.lexaloffle.com/pico-8.php).

## 🎮 About

**PicoRPG** is a retro-style role-playing game
The game is being developed in PICO-8, with features like:

- An overworld map with random encounters  
- Turn-based battle system  
- Spell learning mechanic (use **Absorb** to learn enemy spells)  
- Custom sprites, tiles, and maps  

## 🚀 Getting Started

1. Clone the repo:
   ```sh
   git clone https://github.com/YOURUSERNAME/PicoRPG.git
2. Open the cart in PICO-8
   ```sh
   pico8 run rpg.p8

## Controls

- D-Pad — Move  
- X / ❎ — Confirm / Attack  
- Z / 🅾️ — Cancel / Back  

## How to Play

- Explore the overworld and enter battles.  
- When an enemy is charging a spell, cast **Absorb**.  
  If successful, you permanently learn that spell.  

## Development Notes

### VS Code Tasks for Pico-8 Development

This project includes a set of [VS Code build tasks](.vscode/tasks.json) to make it easy to compile, run, and export the game.

### Available Tasks

- **Ensure build & dist**  
  Utility task to make sure the `build/` and `dist/` directories exist (this runs automatically before a build).

- **Build Pico-8 cart**  
  Compiles `src/main.lua` together with assets from `assets/base.p8` into `build/rpg.p8`.

- **Run Pico-8**  
  Launches Pico-8 with the freshly built cart for testing.

- **Export PNG / Export HTML**  
  Exports the cart to `dist/rpg.png` (cartridge image) or `dist/rpg.html` (embeddable HTML5).

- **Build & Export All**  
  Builds the cart, then exports both PNG and HTML in one step.


### How to Use

1. Open the command palette (**Ctrl+Shift+P** / **⌘⇧P**) → “Tasks: Run Task” or press **Ctrl+Shift+B** to run the default build.
2. Select the task you want to run.
3. Outputs go to:
   - `build/rpg.p8` – compiled cart
   - `dist/` – exported PNG/HTML

### Mojibake / Unicode Issue

If you see special characters like `▶`, `❎`, or `🅾️` appear as nonsense symbols (e.g. `ヌえ`, `ユか✽`), that’s because the Windows build tool (`p8tool.exe`) was defaulting to the system ANSI code page instead of UTF-8.

#### Fix

Set Windows to use UTF-8 for non-Unicode programs:

1. Open **Settings → Time & Language → Language & Region → Administrative language settings**
2. Click **Change system locale…**
3. Check **“Beta: Use Unicode UTF-8 for worldwide language support”**
4. Reboot

After enabling this, the build tasks will preserve all Unicode symbols correctly in your Pico-8 cart.

---

