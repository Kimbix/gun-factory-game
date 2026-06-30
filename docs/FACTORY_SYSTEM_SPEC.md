# Factory System Spec

Engineering spec for the gun-factory simulation core. Game-design balance (recipes, stat numbers, content) is out of scope here; this document covers data model, simulation, placement, and firing integration.

## 1. Core concept

A gun contains a **factory** built inside its **chassis**. The factory is a grid of components (conveyors, splitters, mergers, processors) that physically move **items** from fixed **input ports** to fixed **output chambers**. Each item is `(material_id, stat_block)` and a processor mutates both.

Firing the gun sends raw material into the input ports; the material traverses the factory as discrete items; when an item exits an output chamber it becomes one projectile with that item's `stat_block`.

Implications:
- There is **no pre-computation** of gun behavior. The factory's throughput *is* the gun's performance.
- A slow factory = a slow gun. A factory that transforms materials well = powerful projectiles.
- Stats ride on items; the gun does not have a separate "weapon profile."

## 2. Glossary

- **Chassis** — The gun's housing. Defines the grid, blocked cells, input port positions, output chamber positions, and gun-level constants (fire pattern, magazine size, reload time, fire-rate cap).
- **Factory** — The components placed by the player inside the chassis grid.
- **Item** — Discrete token carried through the grid. `(material_id, stat_block)`. One item per cell, no stacking.
- **Material** — A typed substance (e.g. `powder`, `casing`, `bullet`). Processors may emit a *different* material id (e.g. `powder` → `enhanced_powder`).
- **Stat block** — A mutable dict of stats on an item (damage, velocity, spread, instability, element, …). Defined by gameplay layer; spec only requires it be a serializable bag.
- **Component** — A placed entity occupying one or more cells in the grid, with typed input ports and output ports (face-based, N/E/S/W).
- **Round** — An item that has entered an output chamber; when fired it becomes one projectile.
- **Magazine** — For non-minigun guns, the number of rounds fired between forced reloads. Chassis-defined.
- **Trigger** — Player input that causes a fire attempt.
- **Sim** — The continuous time-based update loop. Always running for the equipped gun only.

## 3. Grid & chassis

- The chassis is an **irregular grid** of cells. Each cell is either `walkable` or `blocked` (part of the gun's frame).
- Dimensions vary per gun (handgun small, minigun large). Single contiguous grid per gun.
- **No Z-axis.** One layer only. (Future: layer stacking with Z-movers — explicitly out of v1 scope.)
- Chassis defines:
  - Grid shape (set of walkable cells, blocked cells).
  - One or more **input ports** placed on the boundary, each with a fixed `material` it accepts.
  - One or more **output chambers** placed on the boundary, each with a `recipe` describing what material/stats it casts into a round.
  - Gun-level firing constants (see Section 7).
- A gun may have **multiple output chambers**. Each chamber is independent.

## 4. Components

### 4.1 General rules
- Each component occupies one or more cells (footprint) anchored at an origin cell. Rotation by 90° increments is allowed; footprints rotate accordingly.
- A component has **typed face-based ports**: each open face is either an `INPUT` port or an `OUTPUT` port. Directional; no omnidirectional routing. For two adjacent components to transfer an item, the facing `OUTPUT` must touch a matching `INPUT`.
- One component per cell. No layering.

### 4.2 Base component types (v1)

| Component | Ports | Behavior |
|-----------|-------|----------|
| **Conveyor** | 1 INPUT, 1 OUTPUT (opposite faces; facing = travel direction) | Moves one item per traversal tick from its INPUT cell to its OUTPUT cell. Has a transport speed (units/sec). Multiple cells → longer belt; behaves as a chain. |
| **Splitter** | 1 INPUT, ≥2 OUTPUTS | Receives items on input; routes to outputs per a policy (default: round-robin; configurable to priority order). |
| **Merger** | ≥2 INPUTS, 1 OUTPUT | Receives items on any input; serializes onto output (FIFO by arrival time; ties broken by port index). |
| **Processor** | recipe-defined INPUT(s) + OUTPUT(s) | Accepts items of matching material(s); emits items of the recipe's output material(s) with the recipe's stat transformations applied. Craft time = `t` seconds per craft. May span multiple cells. |
| **Input Port** (chassis) | 1 OUTPUT (into the grid) | Fixed. Releases raw material into the grid on demand from the firing system (Section 7). |
| **Output Chamber** (chassis) | 1 INPUT (from the grid) | Fixed. Accepts items matching its recipe; stores them as rounds. Has capacity = magazine size. |

Splitters and mergers policies and processor I/O are **face-directional**. The player rotates components at placement time.

### 4.3 Processor model
- A processor is **typed** (e.g. `PowderEnhancer`, `ShellHardener`). Each type defines:
  - A set of accepted input material(s).
  - A produced output material (distinct id from input — processors mutate material identity, not just stats).
  - A stat transformation function on the stat block (`+heat`, multiply `velocity`, etc. — gameplay-defined).
  - A craft time.
- Processors are **not generic recipe-slots**. The component type *is* the recipe. This gives processors identity and pushes the player toward variety.

### 4.4 Recipes (defined per chassis, not per factory)
- A chassis output chamber has a `recipe`:
  - `accepted_material`: the material id it accepts (e.g. `"finished_round"` or `"enhanced_powder"`).
  - Optionally `stat_constraints` (tolerance bands; reject out-of-spec items — gameplay concern, deferred).
- This is how a chassis says what ammo it expects; the factory is the player's race to produce that material.

## 5. Items, materials, stat blocks

- An item is `(material_id: StringName, stats: Dictionary)`.
- Movement through the grid is **discrete** (cell-to-cell), but **time-continuous** (item position is interpolated along the cell path between discrete arrival events for visual smoothness, if rendered).
- One item per cell. If the next cell is occupied, the current item waits. This is the **blocking** mechanic: balancers, sidings, and buffer sizing become real design problems.
- Material identity changes only when a processor emits it. Stats change only via a processor's transformation.
- No item stacking on cells or belts. Splitters/Mergers handle fan-out/in (not stacking).
- **Traceability**: each round fired remembers the exact `stat_block` it had when it exited. The projectile carries that exact stat block. (Section 7.)

## 6. Simulation

- The sim runs **continuously in real time** using a `dt` step, with sim-time multipliers exposed (1×, 4×, max-CPU).
- Only the **equipped gun's** factory simulates. Other owned guns are cold-stored.
- Each tick, per component, in a fixed stable order:
  1. **Inputs pull**: input ports check firing-system demand and release an item onto their output cell if free.
  2. **Conveyors/Processor chains advance**: each item with a free destination cell moves its position forward by `dt * speed`. When it reaches a cell boundary, it attempts to transfer to the next cell. Transfer succeeds only if (a) destination cell is empty and (b) the destination component accepts it (matching ports and material).
  3. **Processors fire**: a processor with all required input items present and craft time elapsed emits its output item onto its output cell (if free).
  4. **Splitters/Mergers route**: choose output per policy; if blocked, item waits.
  5. **Chambers consume**: when an item enters a chamber that matches the recipe, it is removed from the grid and stored as a round.
- Determinism: per-tick processing order is stable (component iteration order). No subprocess-stepping algorithm; just a fixed scan. Acceptable for v1.

## 7. Firing model

Three gun archetypes, declared per chassis:

### 7.1 Archetype: Minigun (constant fire, no reload)
- Mousse held → continuous fire.
- No magazine. No reload.
- Each click sample (default fire-rate interval) attempts to fire **1 round from a chamber with capacity 1**.
- The chamber has capacity 1. Firing drains it. The factory refills it as fast as it can.
- **Effective fire rate = min(chassis fire-rate cap, factory throughput into chamber).**
- No fire, no trigger lock, no reload ever.

### 7.2 Archetype: Semi-auto (constant fire with magazine)
- Click → fire **1 round**.
- Magazine size `M` (chassis). Fire-rate cap F.
- Trigger fires 1 round per click, draining chamber. Chamber capacity = M (target capacity also = M).
- The factory continuously refills the chamber during firing (input ports stay open).
- **Reload condition**: chamber hits 0 AND player attempts to fire → reload sequence begins:
  1. Trigger locks for `R` seconds (chassis reload time). During this, **input ports close** (no new raw material enters the factory). The factory still simulates — items already in transit continue to the chamber.
  2. After `R` seconds, input ports reopen and raw material flows again.
  3. Trigger unlocks only when the chamber holds **M rounds** again.
- A click during reload is stored if it occurs within a small window before trigger unlock; if the wait exceeds the click-stale timeout, the click is dropped with a "click" SFX, no fire.

### 7.3 Archetype: Burst (tap fire with magazine)
- Click → fire **B rounds at once** (B = burst size, chassis-defined; e.g. 3).
- Magazine size `M` (number of rounds stored in chamber; M is a multiple of B so the player thinks in bursts).
- Each click pulls B rounds from chamber.

  - If `chamber >= B`: fire B, decrement by B.
  - If `0 < chamber < B`: **insufficient burst** — do nothing this click (no partial burst). Reload triggers when chamber hits 0 (i.e. when next click can't satisfy a full burst).
- Reload mechanics identical to 7.2 (delay R, input ports closed during delay, refilling to M before unlock).

### 7.4 Across all archetypes
- The **output chamber** is the magazine. There is no separate magazine well component.
- **Multiple chambers**: the chassis declares a **fire pattern** per archetype:
  - **Volley**: fire all chambers that have ≥1 (or ≥B for burst) rounds simultaneously on trigger.
  - **Sequence**: fire chambers in a fixed cyclic order; each trigger advances to the next chamber that can fire.
  - **Burst-volley** (mix): hybrid, e.g. 2-chamber burst sequence.
- **Empty chambers never jam**: volley skips them, sequence skips them. If *no* chamber can satisfy the click, the gun is empty → reload sequence (for magazine archetypes) or no-op (minigun).
- Player feedback for a stale click (click happened but gun can't/won't fire soon): localized `click` SFX, no projectile. (Visual: hammer drops, no round. Sound design deferred.)

### 7.5 Projectiles
- One round fired → one projectile.
- The projectile carries the exact `stat_block` the round had at chamber exit. The gun's baseline stats (chassis) are merged with the round's stats using a per-chassis merge function (gameplay concern; deferred here).
- Spread / fragmentation / element come from the round's stat block, not from the chassis.

## 8. Build-mode validation

A factory is **invalid** if there is no path through walkable-and-component cells from at least one input port to at least one output chamber.

- The game hard-gates exit from build mode on validity: the player cannot finish editing with an invalid factory. (Option to later relax to "warn and allow" if it harms UX.)
- "Path" is a logical graph check over placed components and their matching ports; it does not require correctness of materials (just connectivity).
- Further validity rules (orphan processors, loops with no exit, wrong-material-into-processor) are TBD; only the basic connectivity check is mandatory for v1.
- A runtime debug overlay (toggle) shows, per chamber: throughput (rounds/sec), current fill, error markers. UX ↔ simulation boundary defined in Section 9.

## 9. Debug / UX layer (build mode only)

- The player is not watching the factory during combat; the factory runs invisibly.
- In build mode (screwdriver zoom-in), the factory is rendered: components, pipes, items, item stats, throughput, bottlenecks.
- Debug overlay: heat-map of cell occupancy, per-component craft % , per-chamber fill rate, expected rounds/sec.
- This layer is read-only diagnostic — it does not affect simulation.

## 10. Out of scope (deferred / TBD)

- Item merge rules inside mergers (combine stats of `casing` + `powder` → which stats win?). Owned by gameplay layer.
- Stat block schema (which stats exist, default values, clamp ranges).
- Material catalog and processor catalog (content).
- Chassis catalog (the guns themselves).
- Misfire / jam punishment beyond "no fire + click SFX" if gameplay demands it later.
- Z-axis layers and Z-mover components.
- Whether input ports accept a "category" of materials vs a single material id (currently single id; revisit if needed).
- Save format, multiple-gun inventory management UI.

## 11. Open question for confirmation

This spec is written assuming the following interpretation of the firing model (sections 7.2 and 7.3). Please confirm or correct:

1. **Semi-auto chamber capacity = M = magazine size.** The chamber stores up to M rounds; the factory refills during firing; reload kicks in only when chamber hits 0.
2. **Burst chamber capacity = M, B rounds fire per click, partial bursts do not fire.**
3. **During reload delay R, input ports close**, but the factory continues simulating items already in transit.
4. **Trigger unlocks after chamber refills to full M**, not 1.
5. **Stale click** (click can't be serviced within timeout) = dropped with click SFX, no buffer beyond 1 stored click.