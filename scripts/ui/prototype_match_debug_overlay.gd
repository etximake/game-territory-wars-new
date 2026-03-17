extends Control

class_name PrototypeMatchDebugOverlay

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var phase_label: Label = $PanelContainer/MarginContainer/VBoxContainer/PhaseLabel
@onready var timer_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TimerLabel
@onready var seed_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SeedLabel
@onready var leader_label: Label = $PanelContainer/MarginContainer/VBoxContainer/LeaderLabel
@onready var scoreboard_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ScoreboardLabel
@onready var territory_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TerritoryLabel
@onready var hint_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HintLabel

func _ready() -> void:
	add_to_group(GameConstants.GROUP_DEBUG)
	title_label.text = "Prototype Match Debug"
	hint_label.text = "Space: start match | R: restart match"
	show_waiting_state()

func show_waiting_state() -> void:
	phase_label.text = "Phase: %s" % GameConstants.match_state_name(GameConstants.MatchFlowState.SETUP)
	timer_label.text = "Timer: --:--"
	seed_label.text = "Seed: --"
	leader_label.text = "Leader: --"
	scoreboard_label.text = "Scores:\nWaiting for match start"
	territory_label.text = "Territory:\nWaiting for territory system"

func update_match_state(new_state: int) -> void:
	phase_label.text = "Phase: %s" % GameConstants.match_state_name(new_state)

func update_timer(time_remaining_seconds: float, elapsed_seconds: float) -> void:
	timer_label.text = "Timer: %s left | %s elapsed" % [_format_time(time_remaining_seconds), _format_time(elapsed_seconds)]

func update_seed(match_seed: int) -> void:
	seed_label.text = "Seed: %d" % match_seed

func update_scoreboard(leader_id: int, leaderboard: Array[Dictionary]) -> void:
	if leaderboard.is_empty():
		leader_label.text = "Leader: --"
		scoreboard_label.text = "Scores:\nNo competitors"
		return

	var lines: Array[String] = []
	var leader_name := "--"
	for entry in leaderboard:
		var display_name: String = entry.get("display_name", "Unknown")
		var total_score: float = entry.get("total_score", 0.0)
		var marker := ""
		if entry.get("competitor_id", -1) == leader_id:
			leader_name = display_name
			marker = " <- lead"
		lines.append("%s: %.0f%s" % [display_name, total_score, marker])

	leader_label.text = "Leader: %s" % leader_name
	scoreboard_label.text = "Scores:\n%s" % "\n".join(lines)

func update_territory_summary(lines: PackedStringArray) -> void:
	territory_label.text = "Territory:\n%s" % "\n".join(lines)

func show_match_result(result: MatchResult) -> void:
	phase_label.text = "Phase: %s (%s)" % [GameConstants.match_state_name(result.final_state), result.reason]
	leader_label.text = "Winner: %s" % result.winning_display_name
	update_seed(result.match_seed)
	update_scoreboard(result.winning_competitor_id, result.score_summaries)

func _format_time(value: float) -> String:
	var total_seconds := maxi(0, int(round(value)))
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
