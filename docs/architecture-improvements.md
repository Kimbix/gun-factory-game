# Architecture Improvement Specification

> Targeted refactors to improve testability, decoupling, and maintainability.
> Ordered by priority (P1 = highest impact, most urgently needed).

---

## P1: Dependency Injection Over Singletons

### Problem

`GameSupervisor.instance` and `InterfaceSupervisor.instance` are accessed directly across the codebase. Every script that calls them is tightly coupled to the singleton and cannot be used in isolation for unit testing.

Affected files:
- `GridBuilder.gd` — calls `GameSupervisor.instance.get_player()`
- `GridInteractor.gd` — calls `GameSupervisor.instance.get_player()`
- `BuildingUI.gd` — calls `GameSupervisor.instance.get_player()`
- `AmmoAssembler.gd` — calls `InterfaceSupervisor.instance`
- `MetalProcessor.gd` — calls `InterfaceSupervisor.instance`
- `ItemGenerator.gd` — calls `InterfaceSupervisor.instance`
- `RecipeMachineInterface.gd` — calls `InterfaceSupervisor.instance`
- `SaveGridInterface.gd` — calls both singletons
- `LoadGridInterface.gd` — calls `InterfaceSupervisor.instance`
- `SimpleCharacter.gd` — gets `InterfaceSupervisor.instance`

### Specification

1. **Add `@export var` annotations** to scripts that need external references. Instead of reaching for `GameSupervisor.instance.get_player()`, accept a `player: SimpleCharacter` (or specific subsystem like `building_inventory: PlayerBuildingInventory`) via the inspector or constructor injection.

2. **Wire dependencies at setup time.** The owner/parent of each subsystem passes the required references once during initialization, rather than each child reaching out globally.

3. **Preserve backward compatibility** by keeping singleton access as a fallback only where absolutely necessary (e.g., top-level autoloads), but deprecate its use in new code.

### Example: GridBuilder

```gdscript
# Current — implicit singleton coupling
var player := GameSupervisor.instance.get_player()
if not player.building_inventory.has(selected_info):
    return

# Improved — explicit dependency
@export var building_inventory: PlayerBuildingInventory

func can_place(info: GridComponentInfo) -> bool:
    return building_inventory.has(info)
```

### Example: AmmoAssembler

```gdscript
# Current — reaches into singleton from component code
InterfaceSupervisor.instance.open_interface(interface_instance)

# Improved — inject into setup
@export var interface_supervisor: InterfaceSupervisor

func open_interface() -> void:
    interface_supervisor.open_interface(interface_instance)
```

### Migration Steps

1. Add `@export var` declarations to all scripts that currently access singletons.
2. Update callers (scene files or parent scripts) to wire these exports.
3. Remove singleton references; replace with the injected fields.
4. Remove `GameSupervisor.instance` and `InterfaceSupervisor.instance` patterns from all affected files.

---

## P1: Externalize Hardcoded Resource Paths into GridComponentInfo

### Problem

Building component scripts hardcode `preload("uid://...")` and `load("uid://...")` for their interface scenes and recipe catalogues. This defeats the resource-driven design — changing a building's UI or recipes requires editing the script, not the `.tres` file.

Affected files:
- `AmmoAssembler.gd` — `const INTERFACE := preload("uid://cgrsaa7x25x2o")`, `load("uid://doehfu33ikgrr")`
- `MetalProcessor.gd` — same pattern
- `ItemGenerator.gd` — same pattern
- `Combiner.gd` — same pattern
- `Furnace.gd` — same pattern

### Specification

1. **Add new export fields to `GridComponentInfo.gd`:**

```gdscript
# resources/grid_components/grid_component_info.gd
extends Resource
class_name GridComponentInfo

# Existing fields...
@export var texture: Texture2D
@export var behaviour: Script

# New fields:
@export var interface_scene: PackedScene
@export var recipe_catalogue: BaseRecipeCatalogue  # or Resource
```

2. **Populate these fields in each `.tres` file** (e.g., `ammo_assembler.tres`, `metal_processor.tres`).

3. **Update component scripts** to read from `building._info` instead of using hardcoded `const`/`load()`.

4. **Remove all `preload("uid://...")` and `load("uid://...")`** from component scripts.

### Example

```gdscript
# Current — hardcoded
const INTERFACE := preload("uid://cgrsaa7x25x2o")
func open_interface() -> void:
    var interface_instance := INTERFACE.instantiate()
    InterfaceSupervisor.instance.open_interface(interface_instance)

# Improved — data-driven
func open_interface() -> void:
    var interface_scene := building._info.interface_scene  # from .tres
    if interface_scene:
        var interface_instance := interface_scene.instantiate()
        interface_supervisor.open_interface(interface_instance)
```

### Migration Steps

1. Add new exports to `GridComponentInfo`.
2. Open each `.tres` file for ammo assembler, metal processor, item generator, combiner, furnace.
3. Assign the correct `PackedScene` and recipe catalogue to each.
4. Update each component script to read from `building._info` instead of hardcoded paths.
5. Delete all `const INTERFACE` and `var recipes` hardcoded declarations.

---

## P2: Decompose SimpleCharacter

### Problem

`SimpleCharacter` handles ~7 distinct responsibilities in ~168 lines:
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
@export var regen_rate := 0.5  # per second

var current_health: int

func take_damage(amount: int) -> void: ...
func heal(amount: int) -> void: ...
```

### Migration Steps

1. Create each controller as a separate script.
2. Add them as child Nodes of the player scene.
3. Move the corresponding logic from `SimpleCharacter` into each controller.
4. Wire cross-controller communication via signals (e.g., `HealthController.died → CombatController.stop_attacking`).
5. Keep `SimpleCharacter` as a thin facade that delegates to its children (or remove it entirely and let `GameDirector` reference the subsystems it needs).

---

## P2: EventBus Autoload

### Problem

Cross-system communication currently uses direct singleton access or ad-hoc signal connections. Adding a new listener requires modifying the emitter's code or manually wiring signals in the scene tree.

### Specification

Create an autoload singleton `EventBus` with typed signals for all global game events:

```gdscript
# autoload/event_bus.gd
extends Node
class_name EventBus

signal player_damaged(amount: int, source: Node)
signal player_died
signal player_leveled_up(level: int)
signal building_placed(building: FactoryBuilding, grid_position: Vector2i)
signal building_removed(building: FactoryBuilding, grid_position: Vector2i)
signal item_crafted(item: FactoryItemInfo, count: int)
signal item_consumed(item: FactoryItemInfo, count: int)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal game_state_changed(old_state: int, new_state: int)
signal shop_rerolled
```

All systems emit and subscribe through `EventBus` instead of coupling directly.

### Usage

```gdscript
# Emitter (e.g., PlayerHealthController)
EventBus.player_damaged.emit(10, attacker)

# Subscriber (e.g., DebugUI)
func _ready() -> void:
    EventBus.player_damaged.connect(_on_player_damaged)

func _on_player_damaged(amount: int, source: Node) -> void:
    update_display()
```

### Migration Steps

1. Create `autoload/event_bus.gd` and register it in Project Settings → Autoload.
2. Identify all cross-system communication points in the codebase.
3. Replace direct singleton access with `EventBus.signal.emit(...)` and `EventBus.signal.connect(...)`.
4. Remove old signal wiring from scene trees where possible.

---

## P2: Fix RefCounted Lifecycle for FactoryComponent/FactoryBuilding

### Problem

`FactoryComponent` and `FactoryBuilding` are `RefCounted` but hold references to `PlayerGrid` (a `Node`). This mixes Godot's memory management models — if a grid is freed by the scene tree, the RefCounted objects become dangling references. Reference cycles can also prevent cleanup.

### Specification

1. **Add safety checks** before accessing grid references:

```gdscript
func get_grid() -> PlayerGrid:
    if not is_instance_valid(_grid):
        return null
    return _grid
```

2. **Make `FactoryComponent` a `Node`** (long-term option). This aligns lifecycle with the scene tree, allows child-of-grid parenting, and eliminates mixed-ownership issues.

3. **Short-term fix** — ensure `FactoryBuilding` has a `clear()` or `free_resources()` method that explicitly nulls out references:

```gdscript
func free_resources() -> void:
    if component:
        component.queue_free()  # if Node; or component = null if RefCounted
    grid = null
    _info = null
```

### Migration Steps

1. Add `is_instance_valid` checks in all `FactoryComponent` subclasses that access `building.grid`.
2. Evaluate converting `FactoryComponent` to `Node` — this requires updating all subclass declarations (`extends Node` instead of `extends RefCounted`).
3. Add cleanup hooks in `PlayerGrid.remove_building()` that call `FactoryBuilding.free_resources()`.

---

## P3: Replace Tree-Walking with @export References

### Problem

Several scripts navigate the scene tree with `get_parent().get_parent()` or `get_parent().get_children()` to find siblings, creating implicit coupling to the scene hierarchy structure.

Affected files:
- `GridInteractor` — `_find_builder()` walks `get_parent().get_children()`
- `GridBuilder` — casts `get_parent().get_parent()` to `BuildingUI`

### Specification

Replace all tree-walking with exported references wired in the scene or injected at runtime:

```gdscript
# Current — tree walking
func _find_builder() -> GridBuilder:
    for child in get_parent().get_children():
        if child is GridBuilder:
            return child
    return null

# Improved — explicit dependency
@export var grid_builder: GridBuilder
```

### Migration Steps

1. Add `@export var` declarations for each tree-walked dependency.
2. Open the relevant scene files (e.g., `BuildingUI.tscn`).
3. Wire the exported references via the inspector.
4. Remove the tree-walking code.
5. Remove `_find_builder()` and similar helper functions.

---

## P3: State Machine Abstraction

### Problem

`GameSupervisor` manages game states (GAMEPLAY, BUILDING, PAUSED) with a simple `match` statement. There are no enter/exit hooks, transition guards, or state stacking.

### Specification

Create a lightweight state machine:

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
            # show building UI
        State.GAMEPLAY:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            # hide building UI
        State.PAUSED:
            get_tree().paused = true

func _exit_state(state: int) -> void:
    match state:
        State.PAUSED:
            get_tree().paused = false
```

### Migration Steps

1. Create `StateMachine` script.
2. Add it as a child of `GameSupervisor` or as an autoload.
3. Replace all raw state `match` blocks in `GameSupervisor` with calls to `state_machine.transition()`.
4. Move state enter/exit logic from `GameSupervisor` into the state machine's `_enter_state`/`_exit_state` hooks.

---

## P3: Consolidate Duplicate Interface Subclasses

### Problem

`AmmoAssemblerInterface` and `MetalProcessorInterface` are structurally identical — 17 lines each with the same pattern. Any change to one must be manually mirrored in the other.

### Specification

Merge the duplicate logic into `RecipeMachineInterface` with a generic reference:

```gdscript
# interfaces/recipe_machine_interface.gd
extends InterfaceWindow
class_name RecipeMachineInterface

@export var machine: Node  # generic, set by the building

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
3. Update the `.tscn` files for ammo assembler and metal processor UIs to use `RecipeMachineInterface` directly.
4. Verify both building types still open their interface correctly.

---

## P4: Strengthen BaseEnemy

### Problem

`BaseEnemy` only adds `player` and `add_to_group("enemy")`. `EnemySlime` reimplements `health`, `SPEED`, `take_damage()`, and `on_death` from scratch.

### Specification

Move shared enemy logic into `BaseEnemy`:

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
2. Update `EnemySlime` to inherit from `BaseEnemy` and only override what's different.
3. Add any other enemy types that exist to the same pattern.
4. Remove duplicated code.

---

## P4: Remove VectorTools

### Problem

`VectorTools` is a static class with a single helper function `vector2i_range()`. It adds an unnecessary indirection layer.

### Specification

1. Move `vector2i_range()` logic to `PlayerGrid` as a private or static method.
2. Update all call sites (search: `VectorTools.vector2i_range`).
3. Delete `scripts/helpers/vector_tools.gd`.
4. If other helpers exist in that directory that are genuinely useful, keep them; otherwise remove the directory.

---

## Implementation Order

| Phase | Items | Rationale |
|-------|-------|-----------|
| **Phase 1** | P1: Dependency injection, Externalize resource paths | Both unlock testability and data-driven configuration. Do these first — they change the most fundamental coupling patterns. |
| **Phase 2** | P2: SimpleCharacter decomposition, EventBus | Build on the injection pattern. With DI in place, splitting SimpleCharacter becomes safer. EventBus is quick and immediately useful. |
| **Phase 3** | P2: RefCounted lifecycle fix | Medium-risk, important for memory safety. Do after DI is stable. |
| **Phase 4** | P3: Tree-walking, State machine, Interface consolidation | Lower impact, less risky. Can be done incrementally alongside other work. |
| **Phase 5** | P4: BaseEnemy, VectorTools | Minor quality-of-life. Lowest priority. |

Each phase should be worked on as a separate branch and reviewed independently.
