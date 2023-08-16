class_name Quest
extends Node

@export var quest_id: StringName
## UI string translation key to show
@export var description: String
## List of external nodes that will be made visible and unpaused when quest is active,
## otherwise they will be hidden and paused once inactive.
## Children are included by default.
@export var show_nodes: Array[Node]

## Set to true once the `finished` signal is emitted.
## Can be used in the UI.
@export var done: bool = false

signal updated
signal started
signal finished

var _started = false

func _ready():
	finished.connect(_finished)
	end()

func _finished():
	done = true
	updated.emit()

## Must be called when the quest gets added to the quests array
func start():
	_started = true
	process_mode = Node.PROCESS_MODE_INHERIT
	for node in show_nodes:
		_start_node(node)

	for child in get_children():
		if child is Quest:
			child.start()
		else:
			_start_node(child)

	started.emit()

func _start_node(node):
	if node is Node3D or node is CanvasItem:
		node.visible = true

func get_text():
	return description

## Must be called before the quest gets removed from the quests array
func end():
	process_mode = Node.PROCESS_MODE_DISABLED
	var n = get_child_count()
	for i in range(n, 0, -1):
		var child = get_child(i - 1)
		print(child)
		if child is Quest:
			child.end()
		else:
			_end_node(child)

	for node in show_nodes:
		_end_node(node)
	_started = false

func _end_node(node):
	if node is Node3D or node is CanvasItem:
		node.visible = false
