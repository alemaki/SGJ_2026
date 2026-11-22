class_name Highlightable

extends Area2D

signal on_interaction(is_highlighted: bool)

var _is_highlighted = false;

func switch_highlight() -> void:
	_is_highlighted = not _is_highlighted
	on_interaction.emit(_is_highlighted)
