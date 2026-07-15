# Architecture Improvement Specification

> Targeted refactors to improve testability, decoupling, and maintainability.
> Ordered by priority (P1 = highest impact, most urgently needed).

---

## ✅ Completed

- **P1 — Dependency Injection** — Removed `GameSupervisor.instance` / `InterfaceSupervisor.instance` singletons. All dependencies wired in `GameSupervisor._ready()` via `@export var` or plain var. Removed `_find_builder()` and other tree-walking.
- **P1 — Externalize Hardcoded UIDs** — Added `MachineConfig` and `PillarConfig` resource types. Building `.tres` files now embed config sub-resources with interface scene, recipe catalogue, output item, stat_name, and boost_value. Removed all `preload("uid://...")` / `load("uid://...")` from component scripts.
- **P3 — Tree-Walking** — Removed `get_parent().get_parent()`, `get_node("name")`, and `_find_builder()` patterns. All cross-references are now `@export var` wired by `GameSupervisor`.
- **P2 — InterfaceSupervisor Signals** — Replaced `Callable` properties (`on_pause_requested`, `on_unpause_requested`) with native `signal pause_requested` / `signal unpause_requested`. Connected via `connect()` in `GameSupervisor._ready()` instead of bare `Callable` assignment.
- **P2 — RefCounted Lifecycle Safety** — Added `is_instance_valid` guard to `FactoryComponent.grid` getter, `free_resources()` method on `FactoryBuilding`, and null-guarded all `grid.*` calls in factory component subclasses. `free_resources()` is called from `PlayerGrid.destroy_building()` and `_clear_grid()`. `FactoryComponent` kept as `RefCounted` — `PlayerGrid` owns the lifecycle entirely.

---

## P2: Decompose SimpleCharacter

### Problem

`SimpleCharacter` handles ~7 distinct responsibilities in ~169 lines:
- Movement/input
- PlayerGrid creation and ticking
- Stat pillar application/removal
- Shooting/target finding
- Experience collection
- Health/regen
- Stats sync

It is a god class. Every system needing "the player" gets the monolith.

### Specification

Split into focused child Nodes under the player scene:

| Subsystem | Responsibility | File |
|-----------|---------------|------|
| `PlayerMovementController` | Input → movement, dash, collisions | `scripts/entities/player_movement_controller.gd` |
| `PlayerCombatController` | Targeting, shooting, ammo | `scripts/entities/player_combat_controller.gd` |
| `PlayerGridController` | Owns PlayerGrid, tick timer, pillar callbacks | `scripts/entities/player_grid_controller.gd` |
| `PlayerHealthController` | Health, regen, damage, death | `scripts/entities/player_health_controller.gd` |

### Example Interface

```gdscript
# PlayerHealthController.gd
extends Node
class_name PlayerHealthController

signal health_changed(current: int, max: int)
signal died

@export var max_health := 100
@export var regen_rate := 0.5

var current_health: int

func take_damage(amount: int) -> void: ...
func heal(amount: int) -> void: ...
```

### Migration Steps

1. Create each controller as a separate script.
2. Add them as child Nodes of the player scene.
3. Move the corresponding logic from `SimpleCharacter` into each controller.
4. Wire cross-controller communication via signals.
5. Keep `SimpleCharacter` as a thin facade that delegates to its children.

---

## (Deferred) EventBus Autoload

### Status

Deferred — not needed at current scale.

### Original Problem

Cross-system communication used `Callable` properties and ad-hoc wiring instead of signals.

### What Was Actually Done

The only genuine cross-system awkwardness was in `InterfaceSupervisor`, which used `Callable` properties for pause/unpause. These were replaced with native signals (`pause_requested`, `unpause_requested`), connected via `connect()` in `GameSupervisor._ready()`.

### Why Deferred

After the Dependency Injection refactor, every other cross-reference is already clean `@export var` or direct `signal.connect()` in `_ready()`. Every signal the EventBus would carry has exactly **one listener** today. An EventBus at this scale makes 1:1 communication *less* traceable with zero decoupling benefit.

### Future Criterion

Revisit if any signal accumulates **2+ unrelated subscribers** (e.g., `building_placed` needs to update both grid rendering and a quest system). Until then, keep connections local and explicit.

---

## P2: Fix RefCounted Lifecycle for FactoryComponent/FactoryBuilding

### Problem

`FactoryComponent` and `FactoryBuilding` are `RefCounted` but hold references to `PlayerGrid` (a `Node`). This mixes Godot's memory models — if a grid is freed, the RefCounted objects become dangling. Reference cycles can also prevent cleanup.

### Specification

1. **Add safety checks** before accessing grid references:

```gdscript
func get_grid() -> PlayerGrid:
    if not is_instance_valid(_grid):
        return null
    return _grid
```

2. **Make `FactoryComponent` a `Node`** (long-term). This aligns lifecycle with the scene tree.

3. **Short-term** — add `free_resources()` to `FactoryBuilding` that nulls out references:

```gdscript
func free_resources() -> void:
    if component:
        component = null
    grid = null
    _info = null
```

### Migration Steps

1. Add `is_instance_valid` checks in all `FactoryComponent` subclasses that access `building.grid`.
2. Evaluate converting `FactoryComponent` to `Node`.
3. Add cleanup hooks in `PlayerGrid.remove_building()`.

---

## P3: State Machine Abstraction

### Problem

`GameSupervisor` manages game states (GAMEPLAY, BUILDING, PAUSED) with a simple `match` statement. No enter/exit hooks, transition guards, or state stacking.

### Specification

```gdscript
# scripts/systems/state_machine.gd
extends Node
class_name StateMachine

signal state_changed(from: int, to: int)

enum State {
    GAMEPLAY,
    BUILDING,
    PAUSED,
    MENU,
}

var current_state: int = State.GAMEPLAY:
    set(value):
        if value == current_state:
            return
        var old = current_state
        _exit_state(old)
        current_state = value
        _enter_state(value)
        state_changed.emit(old, value)

func _enter_state(state: int) -> void:
    match state:
        State.BUILDING:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        State.GAMEPLAY:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        State.PAUSED:
            get_tree().paused = true

func _exit_state(state: int) -> void:
    match state:
        State.PAUSED:
            get_tree().paused = false
```

### Migration Steps

1. Create `StateMachine` script.
2. Add as child of `GameSupervisor` or as autoload.
3. Replace raw `match` blocks with `state_machine.transition()`.
4. Move enter/exit logic into the state machine hooks.

---

## P3: Consolidate Duplicate Interface Subclasses

### Problem

`AmmoAssemblerInterface` and `MetalProcessorInterface` are structurally identical — 17 lines each. Changes must be mirrored.

### Specification

Merge into `RecipeMachineInterface` with a generic reference:

```gdscript
# interfaces/recipe_machine_interface.gd
@export var machine: Node

var _machine: FactoryComponent:
    set(v):
        _machine = v
        generate_ui()

func _get_recipe() -> ItemRecipe:
    return _machine.get_recipe() if _machine.has_method("get_recipe") else null

func _set_recipe(r: ItemRecipe) -> void:
    if _machine.has_method("set_recipe"):
        _machine.set_recipe(r)
```

### Migration Steps

1. Remove `AmmoAssemblerInterface.gd` and `MetalProcessorInterface.gd`.
2. Update `RecipeMachineInterface` to handle the generic case.
3. Update `.tscn` files to use `RecipeMachineInterface` directly.

---

## P4: Strengthen BaseEnemy

### Problem

`BaseEnemy` only adds `player` and `add_to_group("enemy")`. `EnemySlime` reimplements `health`, `SPEED`, `take_damage()`, and `on_death` from scratch.

### Specification

```gdscript
# scripts/entities/base_enemy.gd
extends CharacterBody2D
class_name BaseEnemy

signal died

@export var max_health := 20
@export var speed := 50.0
@export var xp_reward := 10

var current_health: int

func take_damage(amount: int) -> void:
    current_health -= amount
    if current_health <= 0:
        _on_death()

func _on_death() -> void:
    died.emit()
    queue_free()
```

### Migration Steps

1. Add shared fields and methods to `BaseEnemy`.
2. Update `EnemySlime` to inherit and only override what's different.
3. Remove duplicated code.

---

## P4: Remove VectorTools

### Problem

`VectorTools` is a static class with a single function `vector2i_range()`. Unnecessary indirection.

### Specification

1. Move `vector2i_range()` to `PlayerGrid` as a private or static method.
2. Update all call sites.
3. Delete `scripts/helpers/vector_tools.gd`.

---

## Remaining Implementation Order

| Phase | Items | Rationale |
|-------|-------|-----------|
| **Next** | P2: SimpleCharacter decomposition | Highest impact remaining. Splitting SimpleCharacter needs careful signal wiring. |
| **Then** | P3: State machine, Interface consolidation | Lower risk, incremental. |
| **Last** | P4: BaseEnemy, VectorTools | Minor quality-of-life. |
