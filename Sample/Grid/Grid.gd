extends Node2D

signal piece_deleted(point)
signal combo_stopped(combo)
signal waiting_started
signal waiting_finished

const pieces_scn = [
	preload("res://Pieces/PieceBeige.tscn"),
	preload("res://Pieces/PieceBlue.tscn"),
	preload("res://Pieces/PieceGreen.tscn"),
	preload("res://Pieces/PiecePink.tscn"),
	preload("res://Pieces/PieceYellow.tscn")
]

const point_obj_scn = preload("res://Point/Point.tscn")
const coin_obj_scn = preload("res://Point/Coin.tscn")

var width: = 7
var height: = 10
var x_start: = 70
var y_start: = 980
var grid_size: = 70
var y_offset: = 2
var all_pieces = []
var touched_pos = Vector2()
var released_pos = Vector2()
var is_touching = false
var is_waiting = false
var combo: int = 0

onready var point: int = 0
onready var pieces_container = $PiecesContainer 
onready var move_sound = $MoveSound

func _ready():
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus, true)
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	yield(get_tree().create_timer(0.5), "timeout")
	AudioServer.set_bus_mute(master_bus, false)


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func spawn_pieces():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var index = floor(rand_range(0, pieces_scn.size()))
				var piece = pieces_scn[index].instance()
				while match_at(i, j, piece.color):
					piece.queue_free()
					index = floor(rand_range(0, pieces_scn.size()))
					piece = pieces_scn[index].instance()
				pieces_container.add_child(piece)
				piece.position = grid_to_pixel(i, j - y_offset)
				piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = piece


func match_at(column, row, color):
	if column >= 2:
		if all_pieces[column-1][row] != null and all_pieces[column-2][row] != null:
			if all_pieces[column-1][row].color == color and all_pieces[column-2][row].color == color:
				return true
	if row >= 2:
		if all_pieces[column][row-1] != null and all_pieces[column][row-2] != null:
			if all_pieces[column][row-1].color == color and all_pieces[column][row-2].color == color:
				return true


func grid_to_pixel(column, row):
	var pixel_pos = Vector2()
	pixel_pos.x = x_start + grid_size * column
	pixel_pos.y = y_start - grid_size * row
	return pixel_pos


func pixel_to_grid(pixel_x, pixel_y) -> Vector2:
	var grid_pos = Vector2()
	grid_pos.x = floor((pixel_x - x_start) / grid_size)
	grid_pos.y = floor((pixel_y - y_start) / -grid_size)
	return grid_pos


func is_in_grid(grid_position: Vector2):
	if grid_position.x >= 0 and grid_position.x < width \
	and grid_position.y >= 0 and grid_position.y < height:
		return true
	else:
		return false


func _process(_delta):
	if not is_waiting:
		touch_input()


func touch_input():
	if Input.is_action_just_pressed("touch"):
		var start_pos = get_global_mouse_position()
		var start_grid = pixel_to_grid(start_pos.x, start_pos.y)
		if is_in_grid(start_grid):
			touched_pos = start_grid
			is_touching = true
	if Input.is_action_just_released("touch"):
		var end_pos = get_global_mouse_position()
		var end_grid = pixel_to_grid(end_pos.x, end_pos.y)
		if is_in_grid(end_grid) and is_touching:
			released_pos = end_grid
			touch_and_release()
		is_touching = false
		if is_waiting:
			while check_matches():
				find_matches()
				yield(get_tree().create_timer(0.3), "timeout")
				delete_matches()
				yield(get_tree().create_timer(0.1), "timeout")
				collapse_columns()
				yield(get_tree().create_timer(0.1), "timeout")
				spawn_pieces()
				yield(get_tree().create_timer(0.2), "timeout")
			emit_signal("combo_stopped", combo)
			combo = 0
			point = 0
			is_waiting = false
			emit_signal("waiting_finished")


func touch_and_release():
	var difference = released_pos - touched_pos
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(touched_pos, Vector2.RIGHT)
		elif difference.x < 0:
			swap_pieces(touched_pos, Vector2.LEFT)
	elif abs(difference.x) < abs(difference.y):
		if difference.y > 0:
			swap_pieces(touched_pos, Vector2.DOWN)
		elif difference.y < 0:
			swap_pieces(touched_pos, Vector2.UP)


func swap_pieces(pos, dir):
	var touched_piece = all_pieces[pos.x][pos.y]
	var target_piece = all_pieces[pos.x + dir.x][pos.y + dir.y]
	if touched_piece != null and target_piece != null:
		all_pieces[pos.x][pos.y] = target_piece
		all_pieces[pos.x + dir.x][pos.y + dir.y] = touched_piece
		touched_piece.move(grid_to_pixel(pos.x + dir.x, pos.y + dir.y))
		target_piece.move(grid_to_pixel(pos.x, pos.y))
		is_waiting = true
		emit_signal("waiting_started")
		move_sound.play()


func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i < width - 2:
					if all_pieces[i+1][j] != null \
					and all_pieces[i+2][j] != null:
						if all_pieces[i+1][j].color == current_color \
						and all_pieces[i+2][j].color == current_color:
							var match_count = 0
							if not all_pieces[i][j].matched:
								point += 1
								match_count += 1
								all_pieces[i][j].point = point
								all_pieces[i][j].make_matched()
							if not all_pieces[i+1][j].matched:
								point += 1
								match_count += 1
								all_pieces[i+1][j].point = point
								all_pieces[i+1][j].make_matched()
							if not all_pieces[i+2][j].matched:
								point += 1
								match_count += 1
								all_pieces[i+2][j].point = point
								all_pieces[i+2][j].make_matched()
							if match_count == 3:
								spawn_coin(all_pieces[i][j])
								combo += 1
								point *= combo
				if j < height - 2:
					if all_pieces[i][j+1] != null \
					and all_pieces[i][j+2] != null:
						if all_pieces[i][j+1].color == current_color \
						and all_pieces[i][j+2].color == current_color:
							var match_count = 0
							if not all_pieces[i][j].matched:
								point += 1
								match_count += 1
								all_pieces[i][j].point = point
								all_pieces[i][j].make_matched()
							if not all_pieces[i][j+1].matched:
								point += 1
								match_count += 1
								all_pieces[i][j+1].point = point
								all_pieces[i][j+1].make_matched()
							if not all_pieces[i][j+2].matched:
								point += 1
								match_count += 1
								all_pieces[i][j+2].point = point
								all_pieces[i][j+2].make_matched()
							if match_count == 3:
								spawn_coin(all_pieces[i][j])
								combo += 1
								point += combo


func spawn_coin(piece):
	var coin_obj = coin_obj_scn.instance()
	coin_obj.position = piece.position
	call_deferred("add_child", coin_obj)


func delete_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					spawn_point(all_pieces[i][j])
					emit_signal("piece_deleted", all_pieces[i][j].point)
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null


func spawn_point(piece):
	var point_obj = point_obj_scn.instance()
	point_obj.position = piece.position
	point_obj.get_node("Stars").amount = int(min(float(piece.point), 100.0))
	point_obj.get_node("PointLabelPos/PointLabel").text = str(piece.point)
	call_deferred("add_child", point_obj)


func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break


func check_matches() -> bool:
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color):
					return true
	return false
