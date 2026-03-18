extends Control

class_name PrototypeMatchDebugOverlay

const SCOREBOARD_MAX_ROWS := 6
const OWNERSHIP_MAX_ROWS := 4

@onready var phase_label: Label = $TopBar/TopMargin/TopRow/PhaseLabel
@onready var timer_label: Label = $TopBar/TopMargin/TopRow/TimerLabel
@onready var seed_label: Label = $TopBar/TopMargin/TopRow/SeedLabel
@onready var camera_label: Label = $TopBar/TopMargin/TopRow/CameraLabel
@onready var leader_label: Label = $OwnershipPanel/OwnershipMargin/OwnershipVBox/LeaderLabel
@onready var momentum_label: Label = $OwnershipPanel/OwnershipMargin/OwnershipVBox/MomentumLabel
@onready var ownership_label: Label = $OwnershipPanel/OwnershipMargin/OwnershipVBox/OwnershipLabel
@onready var scoreboard_label: Label = $ScorePanel/ScoreMargin/ScoreVBox/ScoreboardLabel
@onready var readability_label: Label = $ScorePanel/ScoreMargin/ScoreVBox/ReadabilityLabel
@onready var build_panel: PanelContainer = $BuildPanel
@onready var build_list_label: Label = $BuildPanel/BuildMargin/BuildVBox/BuildListLabel
@onready var build_hint_label: Label = $BuildPanel/BuildMargin/BuildVBox/BuildHintLabel
@onready var event_banner: PanelContainer = $EventBanner
@onready var event_label: Label = $EventBanner/EventLabel
@onready var hint_label: Label = $HintLabel
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_winner_label: Label = $ResultPanel/ResultMargin/ResultVBox/ResultWinnerLabel
@onready var result_reason_label: Label = $ResultPanel/ResultMargin/ResultVBox/ResultReasonLabel
@onready var result_scores_label: Label = $ResultPanel/ResultMargin/ResultVBox/ResultScoresLabel

var _build_panel_visible: bool = false
var _banner_until_msec: int = 0

func _ready() -> void:
	add_to_group(GameConstants.GROUP_DEBUG)
	hint_label.text = "Space start | R restart | C camera | B builds"
	show_waiting_state()
	set_process(true)

func _process(_delta: float) -> void:
	if _banner_until_msec > 0 and Time.get_ticks_msec() >= _banner_until_msec:
		event_banner.visible = false
		_banner_until_msec = 0

func show_waiting_state() -> void:
	phase_label.text = "Phase: %s" % GameConstants.match_state_name(GameConstants.MatchFlowState.SETUP)
	timer_label.text = "03:00"
	seed_label.text = "Seed: --"
	camera_label.text = "Cam: Gameplay"
	leader_label.text = "Leader: --"
	momentum_label.text = "Momentum: --"
	ownership_label.text = "Ownership: waiting"
	scoreboard_label.text = "Waiting for match start"
	readability_label.text = "HUD ready\nOwnership > active > identity"
	result_panel.visible = false
	event_banner.visible = false

func update_match_state(new_state: int) -> void:
	phase_label.text = "Phase: %s" % GameConstants.match_state_name(new_state)
	if new_state != GameConstants.MatchFlowState.ENDED:
		result_panel.visible = false

func update_timer(time_remaining_seconds: float, _elapsed_seconds: float) -> void:
	timer_label.text = _format_time(time_remaining_seconds)

func update_seed(match_seed: int) -> void:
	seed_label.text = "Seed: %d" % match_seed

func update_camera_mode(label_text: String) -> void:
	camera_label.text = "Cam: %s" % label_text

func update_scoreboard(leader_id: int, leaderboard: Array[Dictionary]) -> void:
	if leaderboard.is_empty():
		leader_label.text = "Leader: --"
		momentum_label.text = "Momentum: --"
		scoreboard_label.text = "No competitors"
		return

	var lines: Array[String] = []
	var leader_name := "--"
	var lead_score := 0.0
	var runner_up_score := 0.0
	for index in range(mini(leaderboard.size(), SCOREBOARD_MAX_ROWS)):
		var entry := leaderboard[index]
		var display_name := _short_name(String(entry.get("display_name", "Unknown")))
		var total_score := float(entry.get("total_score", 0.0))
		var marker := ""
		if int(entry.get("competitor_id", -1)) == leader_id:
			leader_name = display_name
			lead_score = total_score
			marker = "  LEAD"
		elif runner_up_score <= 0.0:
			runner_up_score = total_score
		lines.append("%s  %.0f%s" % [display_name, total_score, marker])
	leader_label.text = "Leader: %s" % leader_name
	momentum_label.text = "Momentum: +%.0f" % maxf(lead_score - runner_up_score, 0.0)
	scoreboard_label.text = "\n".join(lines)

func update_spectator_snapshot(leaderboard: Array[Dictionary], owner_percentages: Dictionary, contested_cells: int) -> void:
	if leaderboard.is_empty():
		return
	var ownership_lines: Array[String] = []
	ownership_lines.append("Hot zones: %d" % contested_cells)
	for index in range(mini(leaderboard.size(), OWNERSHIP_MAX_ROWS)):
		var entry := leaderboard[index]
		var competitor_id := int(entry.get("competitor_id", -1))
		var display_name := _short_name(String(entry.get("display_name", "Unknown")))
		var territory_share := float(owner_percentages.get(competitor_id, 0.0)) * 100.0
		ownership_lines.append("%s  %.0f%%" % [display_name, territory_share])
	ownership_label.text = "Ownership:\n%s" % "\n".join(ownership_lines)
	readability_label.text = "Name tags on marbles\nB for builds | C for camera"


func update_territory_summary(lines: PackedStringArray) -> void:
	for line in lines:
		if String(line).begins_with("Contested Cells:"):
			readability_label.text = "Territory: %s
Name tags on marbles
B for builds | C for camera" % String(line).replace("Contested Cells:", "Hot zones")
			return

func update_build_selector(roster: Array[Dictionary]) -> void:
	var lines: Array[String] = []
	for entry in roster:
		var display_name := _short_name(String(entry.get("display_name", "Unknown")))
		var marble_label := "Base Marble"
		var marble_definition_variant: Variant = entry.get("marble_definition", null)
		if marble_definition_variant is MarbleDefinition:
			marble_label = marble_definition_variant.display_name
		var weapon_label := "No Weapon"
		var weapon_variant: Variant = entry.get("weapon_definition", null)
		if weapon_variant is WeaponDefinition:
			weapon_label = weapon_variant.display_name
		lines.append("%s\n%s + %s" % [display_name, marble_label, weapon_label])
	build_list_label.text = "\n\n".join(lines)
	build_hint_label.text = "B toggle builds | Selected builds come from MatchConfig"

func toggle_build_selector() -> void:
	_build_panel_visible = not _build_panel_visible
	build_panel.visible = _build_panel_visible

func set_build_selector_visible(value: bool) -> void:
	_build_panel_visible = value
	build_panel.visible = value

func show_event_banner(message: String, accent: Color = Color(1.0, 0.95, 0.7, 0.96), duration_seconds: float = 1.8) -> void:
	event_label.text = message
	event_label.add_theme_color_override("font_color", accent)
	event_banner.visible = true
	_banner_until_msec = Time.get_ticks_msec() + int(duration_seconds * 1000.0)

func show_match_result(result: MatchResult) -> void:
	result_panel.visible = true
	result_winner_label.text = "%s wins" % result.winning_display_name
	result_reason_label.text = "Reason: %s | Seed %d" % [result.reason, result.match_seed]
	var lines: Array[String] = []
	for index in range(mini(result.score_summaries.size(), 3)):
		var entry := result.score_summaries[index]
		lines.append("%s  %.0f" % [_short_name(String(entry.get("display_name", "Unknown"))), float(entry.get("total_score", 0.0))])
	result_scores_label.text = "Top results\n%s" % "\n".join(lines)

func _short_name(name_text: String) -> String:
	return name_text.replace("Player ", "P").replace("AI ", "AI")

func _format_time(value: float) -> String:
	var total_seconds := maxi(0, int(round(value)))
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
