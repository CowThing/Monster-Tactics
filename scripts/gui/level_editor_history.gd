extends Reference

const MAX_HISTORY = 100000

var history = []
var history_pos = 0

func clear_history():
	history = []

func add_history(map):
	if history_pos > 0:
		for i in range(history_pos):
			history.pop_front()
		history_pos = 0
	
	history.push_front(map.duplicate())
	
	if history.size() > MAX_HISTORY:
		history.pop_back()

func undo():
	if not history.empty():
		history_pos = clamp(history_pos + 1, 0, history.size() - 1)
		return history[history_pos]

func redo():
	if history_pos > 0:
		history_pos -= 1
		return history[history_pos]
