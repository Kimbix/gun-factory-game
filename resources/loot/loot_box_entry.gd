class_name LootBoxEntry
extends Resource
## A single weighted entry inside a [LootBoxTable].
## [member weight] is relative — entries with higher weights are picked
## proportionally more often by [method LootBoxTable.pick].

@export var scene: PackedScene
@export_range(0.0, 100.0) var weight: float = 1.0
