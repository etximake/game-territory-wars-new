extends RefCounted

class_name MatchResult

var winning_competitor_id: int = -1
var winning_display_name: String = ""
var final_state: int = GameConstants.MatchFlowState.ENDED
var reason: String = ""
var reached_score_target: bool = false
var time_elapsed_seconds: float = 0.0
var match_seed: int = 0
var score_summaries: Array[Dictionary] = []

func to_summary() -> Dictionary:
	return {
		"winning_competitor_id": winning_competitor_id,
		"winning_display_name": winning_display_name,
		"final_state": final_state,
		"reason": reason,
		"reached_score_target": reached_score_target,
		"time_elapsed_seconds": time_elapsed_seconds,
		"match_seed": match_seed,
		"score_summaries": score_summaries.duplicate(true),
	}
