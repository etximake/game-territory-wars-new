extends RefCounted

class_name MatchCompetitorState

var competitor_id: int
var display_name: String
var is_player: bool
var color: Color
var marble_definition: MarbleDefinition
var total_score: float = 0.0
var score_breakdown: Dictionary = {}

func _init(id: int, name: String, player_controlled: bool, competitor_color: Color, marble_resource: MarbleDefinition = null) -> void:
	competitor_id = id
	display_name = name
	is_player = player_controlled
	color = competitor_color
	marble_definition = marble_resource

func add_score(source: int, amount: float) -> void:
	total_score += amount
	score_breakdown[source] = score_breakdown.get(source, 0.0) + amount

func reset() -> void:
	total_score = 0.0
	score_breakdown.clear()

func to_summary() -> Dictionary:
	return {
		"competitor_id": competitor_id,
		"display_name": display_name,
		"is_player": is_player,
		"color": color,
		"marble_definition": marble_definition,
		"total_score": total_score,
		"score_breakdown": score_breakdown.duplicate(true),
	}
