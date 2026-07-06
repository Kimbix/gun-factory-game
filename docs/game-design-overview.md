# Gun Factory Game — Design Overview

> Extracted from Excalidraw diagram `Untitled-2025-10-02-1131(1).excalidraw`
> with additional context from the existing project codebase.

---

## Core Concept

Factory-building game where the factory produces bullets that you shoot in a separate combat game-mode. Two interlocking loops: **factory mode** (build, optimize, craft) feeds into **combat mode** (shoot, loot, progress).

---

## Game Modes

### Factory Mode
Grid-based factory building. Place components on a grid, connect them, and manage item flow to assemble bullet types.

### Combat Mode
Top-down shooter / wave-based combat using the bullets you crafted. Pre-set waves per stage, increasing difficulty.

---

## Gameplay Loop

```
Player starts with a simple factory
         |
         v
    Basic combat
         |
         v
    Defeat enemies
         |
         +---> XP (levels up)
         +---> $ / Dollars (buy components)
         +---> Resources (used in factory as items)
         |
         v
    Improve factory -> craft better bullets -> harder combat -> better loot
```

### Combat Rewards

- **XP** — level up to unlock stat-boosting buildings
- **Dollars ($)** — spent in the shop to buy factory components
- **Resources** — raw materials that flow through the factory to produce bullets

---

## Factory Components

### Existing in Codebase

| Component | Inputs | Outputs | Description |
|-----------|--------|---------|-------------|
| **Conveyor Belt** | 1 item (any direction) | Opposite direction | Moves items along the grid. 4-port (N, S, E, W). |
| **Item Generator** | None | 1 configurable item | Produces a chosen item on a 40-tick cooldown. Interface lets player select which item to generate. |
| **Combiner** | bullet_casing + gunpowder (1:1) | loaded_bullet | Combines two resources into one output. 60-tick cooldown. |
| **Item Receiver** | 1 item (any direction) | Consumes it | Destroys received items and emits a signal (`output_item`). Acts as the exit point from the factory. |

### Factory Items (Resources)

| Item | Source | Used By | Description |
|------|--------|---------|-------------|
| **bullet_casing** | Item Generator (or loot) | Combiner | Shell casing — half of a bullet |
| **gunpowder** | Item Generator (or loot) | Combiner | Propellant — other half of a bullet |
| **loaded_bullet** | Combiner output | Item Receiver / Combat | Finished bullet ready to shoot |

### Factory Blocks (from diagram)

From the Excalidraw, three conceptual block types were sketched (not yet implemented):

- **Filter Block** — 1 input, 2 outputs (filter-pass and filter-reject). Routes items based on a condition.
- **Storage Block** — 1 input, 1 output. Holds items in a buffer. Probably has a capacity.
- **Improvement Block** — Input, no output ports (self-contained). Icon depends on the stat it boosts. Multiple tiers possible.

---

## Progression System

### Leveling Up
- Player earns XP from kills
- Leveling up rewards **stat-boosting buildings**
- These buildings occupy factory space but give general bonuses (fire rate, damage, move speed, etc.)

### Economy
- **Basic components** (conveyors, filters, storage) always available in the shop
- **Special components** rotate in the shop every minute
- Reroll early for a price in money

### Boss Waves
- Certain waves contain a boss enemy
- Boss defeat rewards a **special upgrade at random**
  - Permanent stat bonuses
  - Special boss buildings (unique effects, can't be bought)

### Meta-progression
- Buy higher tiers of standard components in the shop
- Purchase buildings that can appear in the shop

---

## Architecture Notes

- Built in **Godot 4**
- Components use a **grid system** (`PlayerGrid`) with cells sized by `GRID_TEXTURE_SIZE`
- Items are placed as physical objects on the grid at runtime
- Component behaviours are defined by a `Script` reference on the `GridComponentInfo` resource
- Every component receives a `tick()` call each frame — movement, processing, and cooldowns all tick-based
- `Port` system handles item I/O with facing directions and modes (input, output, bidirectional)
- `Buildings` have a `rotation` state (NORMAL, CLOCKWISE, COUNTERCLOCKWISE, FLIPPED)

---

## Asset Inventory

### Factory Components (sprites)
- `assets/factory_components/spr_conveyor.png`
- `assets/factory_components/spr_combiner.png`
- `assets/factory_components/spr_generator.png`
- `assets/factory_components/spr_receiver.png`

### Factory Items (sprites)
- `assets/factory_items/spr_bulletCasing.png`
- `assets/factory_items/spr_gunpowder.png`
- `assets/factory_items/spr_loadedBullet.png`
