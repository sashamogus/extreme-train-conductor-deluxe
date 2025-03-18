package game

import "core:fmt"
import "core:math"
import "core:math/rand"

import rl "vendor:raylib"

RENDER_WIDTH :: 624
RENDER_HEIGHT :: 404

WINDOW_WIDTH :: RENDER_WIDTH * 2
WINDOW_HEIGHT :: RENDER_HEIGHT * 2

FRAME_RATE :: 60.0
DELTA_TIME :: 1.0 / FRAME_RATE

LEVER_SIZE :: 48
LEVER_PAD :: 20
LEVER_AREA :: RENDER_HEIGHT - 100

Game_Memory :: struct {
	run: bool,
	render_target: rl.RenderTexture,
	textures: [Texture_Tag]rl.Texture,

	game_state_machine: Game_State_Machine,
	fade_out: bool,
	fade_out_timer: f32,
	fade_in: bool,
	fade_in_timer: f32,

	wave_countdown: f32,

	current_wave: int,
	current_level: int,
	score: int,
	highscore: int,
	heart: int,
	
	rail_grid: Rail_Grid,
	levers: [dynamic]Lever,
	train_pool: Train_Pool,
	train_spawners: [dynamic]Train_Spawner,
	particles: [dynamic]Particle,
}


@(rodata)
textures_path := [Texture_Tag]cstring {
	.Rail_Up_Down = "assets/rail_up_down.png",
	.Rail_Sideway = "assets/rail_sideway.png",
	.Rail_Switch_UD = "assets/rail_switch_ud.png",
	.Rail_Switch_SW = "assets/rail_switch_sw.png",
	.Lever = "assets/lever.png",
	.Train = "assets/train.png",
	.Cargo = "assets/cargo.png",
	.Danger = "assets/danger.png",
	.Icon_Normal = "assets/icon_normal.png",
	.Icon_Fast = "assets/icon_fast.png",
	.Icon_Long = "assets/icon_long.png",
	.Arrow_Normal = "assets/arrow_normal.png",
	.Arrow_Fast = "assets/arrow_fast.png",
	.Arrow_Long = "assets/arrow_long.png",
}

Texture_Tag :: enum {
	Rail_Up_Down,
	Rail_Sideway,
	Rail_Switch_UD,
	Rail_Switch_SW,
	Lever,
	Train,
	Cargo,
	Danger,
	Icon_Normal,
	Icon_Fast,
	Icon_Long,
	Arrow_Normal,
	Arrow_Fast,
	Arrow_Long,
}

RAIL_SIZE :: 16
RAIL_GRID_WIDTH :: 39
RAIL_GRID_HEIGHT :: 19
Rail_Grid :: [RAIL_GRID_HEIGHT][RAIL_GRID_WIDTH]Rail

Rail_Type :: enum {
	None,
	Up_Down,
	Sideway,
	Switch,
}

Rail :: struct {
	type: Rail_Type,
	switch_index: int,
}

Axis :: enum {
	Up_Down,
	Sideway,
}

Train_Handle :: struct {
	index: int,
	generation: int,
}

TRAIN_SIZE :: 16
TRAIN_CLICK_SIZE :: 24
TRAIN_CLICK_OFFSET :: (TRAIN_CLICK_SIZE - TRAIN_SIZE) / 2
TRAIN_OFFSET :: 18

Train_Type :: enum {
	Cargo,
	Head,
}

@(rodata)
train_score := [Train_Type]int {
	.Cargo = 10,
	.Head = 20,
}

Train :: struct {
	used: bool, // true if this slot is used
	next_index: int, // index of next free slot
	generation: int, // incremented everytime this slot is freed
	
	type: Train_Type,
	train_speed: f32,
	spawner_index: int,
	axis: Axis,
	
	train_fwd: Maybe(Train_Handle),
	train_back: Maybe(Train_Handle),
	
	pos: [2]f32,
	pos_new: [2]f32,
	speed: f32,
	dir: [2]f32,

	stopped: bool,
	stop_timer: f32,
	explode: bool,
	explode_timer: f32,
	scored: bool,
}

Train_Pool :: struct {
	arr: [dynamic]Train,
	used: int,
	head: int,
}

Train_Spawn_Type :: enum {
	Normal,
	Fast,
	Long,
}

Train_Spawner :: struct {
	pos: [2]int,
	axis: Axis,

	timer: f32,
	spawn_time: f32,
	spawn_type: Train_Spawn_Type,

	quota_normal: int,
	quota_fast: int,
	quota_long: int,
	quota_dir_change: int,

	dir_change_queued: bool,

	train_active: int, // number of trains active on this rail
	train_direction: int, // direction of train to spawn
	train_speed: f32,
}

@(rodata)
lever_colors := [?]rl.Color {
	rl.BLUE,
	rl.GREEN,
	rl.BEIGE,
	rl.RED,
}

@(rodata)
lever_keys := [?]rl.KeyboardKey {
	.Q,
	.W,
	.E,
	.R,
}


Lever :: struct {
	state: bool,
	state_just_changed: bool,

	pos: [2]f32,
	hover: bool,
}

Particle :: struct {
	pos: [2]f32,
	vel: [2]f32,
	rot: f32,
	vel_rot: f32,
	size: f32,

	color: rl.Color,
	lifetime: f32,
	time_elapsed: f32,
}

game_camera :: proc() -> rl.Camera2D {
	return {
		zoom = 1,
	}
}

mouse_position :: proc() -> [2]f32 {
	return rl.GetMousePosition() * [2]f32 {
		f32(RENDER_WIDTH) / f32(WINDOW_WIDTH),
		f32(RENDER_HEIGHT) / f32(WINDOW_HEIGHT),
	}
}

init :: proc() {
	load_assets()
	enter_title(true)
}

load_assets :: proc() {
	for t in Texture_Tag {
		rl.UnloadTexture(g_mem.textures[t])
		g_mem.textures[t] = rl.LoadTexture(textures_path[t])
	}
}

debug_rects: [dynamic]rl.Rectangle

game_start :: proc() {
	g_mem.current_wave = 1
	g_mem.current_level = 0
	g_mem.score = 0
	g_mem.heart = 10
	free_all_trains()
	load_level(levels[g_mem.current_level])
}

load_level :: proc(level: Level) {
	g_mem.rail_grid = level.rail_grid
	resize(&g_mem.levers, level.lever_num)
	resize(&g_mem.train_spawners, len(level.train_spawners))
	copy(g_mem.train_spawners[:], level.train_spawners)
}

wave_start :: proc() {
	spawn_time := 8.0 * math.pow(0.99, f32(g_mem.current_wave))
	train_speed := 120.0 * math.pow(1.01, f32(g_mem.current_wave))
	for &s, i in g_mem.train_spawners {
		s.timer = 4 + f32(i) * spawn_time / 2 + random_scaler(2)
		s.spawn_time = spawn_time

		s.quota_normal = 5
		s.quota_fast = g_mem.current_wave / 3
		s.quota_long = g_mem.current_wave / 5
		s.quota_dir_change = 2 + g_mem.current_wave / 7
		
		s.train_active = 0
		s.train_direction = i % 2 == 0 ? 1 : -1
		s.train_speed = train_speed

		decide_spawn_type(i)
	}
}

update :: proc() {
	free_all(context.temp_allocator)

	debug_rects = make([dynamic]rl.Rectangle, context.temp_allocator)

	when ODIN_DEBUG {
		if rl.IsKeyPressed(.J) {
			fmt.println("Hot reloading assets...")
			load_assets()
		}
	}
	
	rl.BeginDrawing()

	// Draw game into render texture
	rl.BeginTextureMode(g_mem.render_target)
	rl.ClearBackground(rl.DARKGREEN)

	// Draw game elements
	rl.BeginMode2D(game_camera())
	
	game_state_update()
	g_mem.highscore = max(g_mem.highscore, g_mem.score)
	
	for rect in debug_rects {
		rl.DrawRectangleRec(rect, rl.RED)
		rl.DrawRectangleLinesEx(rect, 1, rl.GREEN)
	}
	
	rl.EndMode2D()
	rl.EndTextureMode()

	
	// Draw render texture scaled
	src := rl.Rectangle { 0, 0, RENDER_WIDTH, -RENDER_HEIGHT, }
	dst := rl.Rectangle { 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, }
	rl.DrawTexturePro(g_mem.render_target.texture, src, dst, 0, 0, rl.WHITE)

	if g_mem.fade_out {
		c := rl.BLACK
		c.a = 255 - u8(g_mem.fade_out_timer * 255)
		rl.DrawRectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, c)
	}
	if g_mem.fade_in {
		c := rl.BLACK
		c.a = u8(g_mem.fade_in_timer * 255)
		rl.DrawRectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, c)
	}
	
	rl.EndDrawing()
}

draw_text_centered :: proc(text: cstring, x, y, font_size: i32, color: rl.Color) {
	text_size := rl.MeasureText(text, font_size)
	x := x - text_size / 2
	rl.DrawText(text, x, y, font_size, rl.WHITE)
}

get_rail :: proc(pos: [2]f32) -> Maybe(Rail) {
	p := [2]int { int(pos.x / RAIL_SIZE), int(pos.y / RAIL_SIZE) }
	if p.x < 0 || p.x >= RAIL_GRID_WIDTH ||
	   p.y < 0 || p.y >= RAIL_GRID_HEIGHT {
		return nil
	}

	return g_mem.rail_grid[p.y][p.x]
}


get_rail_axis :: proc(rail: Rail) -> Maybe(Axis) {
	switch rail.type {
	case .None:
		return nil
	case .Up_Down:
		return .Up_Down
	case .Sideway:
		return .Sideway
	case .Switch:
		if g_mem.levers[rail.switch_index].state {
			return .Sideway
		} else {
			return .Up_Down
		}
	}
	return nil
}

update_rails :: proc() {
	for x in 0..<RAIL_GRID_WIDTH {
		for y in 0..<RAIL_GRID_HEIGHT {
			rail := g_mem.rail_grid[y][x]
			if rail.type == .Switch {
				if rail.switch_index < len(g_mem.levers) {
					lever := g_mem.levers[rail.switch_index]
					if lever.state_just_changed {
						for _ in 0..<4 {
							pos := [2]f32 { f32(x * RAIL_SIZE), f32(y * RAIL_SIZE), }
							pos += RAIL_SIZE / 2
							pos += random_vector(10)
							vel := random_unit_vector() * 50
							rot := random_angle()
							vel_rot := random_scaler(1000)
							size := 10 + random_scaler(2)
							color := lever_colors[rail.switch_index]
							color.a = 192
							add_particle(pos, vel, rot, vel_rot, size, color, 0.4)
						}
					}
				}
			}
		}
	}
}

draw_rail :: proc(texture: rl.Texture, x, y: i32, color: rl.Color) {
	rl.DrawTexture(texture, x + 1, y + 1, rl.BLACK)
	rl.DrawTexture(texture, x, y, color)
}

draw_rails :: proc() {
	for x in 0..<RAIL_GRID_WIDTH {
		px := i32(x * RAIL_SIZE)
		for y in 0..<RAIL_GRID_HEIGHT {
			py := i32(y * RAIL_SIZE)
			rail := g_mem.rail_grid[y][x]
			switch rail.type {
			case .None:
			case .Up_Down:
				texture := g_mem.textures[.Rail_Up_Down]
				rl.DrawTexture(texture, px + 1, py + 1, rl.BLACK)
				rl.DrawTexture(texture, px, py, rl.WHITE)
			case .Sideway:
				texture := g_mem.textures[.Rail_Sideway]
				rl.DrawTexture(texture, px + 1, py + 1, rl.BLACK)
				rl.DrawTexture(texture, px, py, rl.WHITE)
			case .Switch:
				lever_state := false
				if rail.switch_index < len(g_mem.levers) {
					lever := g_mem.levers[rail.switch_index]
					lever_state = lever.state
				}
				
				tex_active: rl.Texture
				if lever_state {
					tex_active = g_mem.textures[.Rail_Switch_SW]
				} else {
					tex_active = g_mem.textures[.Rail_Switch_UD]
				}
				lever_color := lever_colors[rail.switch_index]
				rl.DrawTexture(tex_active, px + 1, py + 1, rl.BLACK)
				rl.DrawTexture(tex_active, px, py, lever_color)
			}

		}
	}
}

update_levers :: proc() {
	m := mouse_position()
	lgth := len(g_mem.levers)
	w := lgth * LEVER_SIZE + (lgth - 1) * LEVER_PAD
	x := f32((RENDER_WIDTH / 2) - w / 2)
	y := f32(LEVER_AREA + ((RENDER_HEIGHT - LEVER_AREA - LEVER_SIZE) / 2))
	for &l, i in g_mem.levers {
		l.state_just_changed = false
		l.pos = { x, y - 16 }
		rec := rl.Rectangle {
			l.pos.x,
			l.pos.y,
			LEVER_SIZE,
			LEVER_SIZE,
		}
		
		l.hover = rl.CheckCollisionPointRec(m, rec)
		pressed: bool
		pressed |= rl.IsKeyPressed(lever_keys[i])
		pressed |= l.hover && rl.IsMouseButtonPressed(.LEFT)
		if pressed {
			l.state = !l.state
			l.state_just_changed = true
			center := l.pos + { LEVER_SIZE / 2, LEVER_SIZE }
			for _ in 0..<4 {
				pos := center + random_vector(10)
				vel := [2]f32 { 0, 15 } + random_vector(30)
				rot := random_scaler(360)
				vel_rot := random_scaler(10)
				size := 5 + random_scaler(5)
				color := rl.ColorLerp(lever_colors[i], rl.GRAY, 0.8)
				add_particle(pos, vel, rot, vel_rot, size, color, 0.8)
			}
		}

		x += LEVER_SIZE + LEVER_PAD 
	}
}

draw_levers :: proc() {
	rl.DrawRectangle(0, LEVER_AREA, RENDER_WIDTH, RENDER_HEIGHT - LEVER_AREA, rl.GRAY)
	for l, i in g_mem.levers {
		c := lever_colors[i % len(lever_colors)]
		c = rl.ColorBrightness(c, 0.8)
		if l.hover {
			c = rl.ColorBrightness(c, -0.5)
		}
		
		src := rl.Rectangle {
			l.state ? 0 : LEVER_SIZE,
			0,
			LEVER_SIZE,
			LEVER_SIZE,
		}
		rl.DrawTextureRec(g_mem.textures[.Lever], src, l.pos, c)

		c = lever_colors[i % len(lever_colors)]
		FONT_SIZE :: 20
		key_rec := rl.Rectangle {
			l.pos.x + (LEVER_SIZE - FONT_SIZE) / 2,
			l.pos.y + LEVER_SIZE + 5,
			FONT_SIZE,
			FONT_SIZE,
		}
		rl.DrawRectangleRec(key_rec, c)
		rl.DrawText(fmt.ctprint(lever_keys[i]), i32(key_rec.x) + 4, i32(key_rec.y), FONT_SIZE, rl.WHITE)
	}
}

spawn_train :: proc(spawner_index: int, type: Train_Type, length: int, speed_mult: f32) {
	s := &g_mem.train_spawners[spawner_index]

	head_handle := alloc_train()
	s.train_active += 1
	
	head := get_train(head_handle)
	head.type = type
	head.train_speed = s.train_speed * speed_mult
	head.spawner_index = spawner_index
	head.axis = s.axis
	
	head.train_fwd = nil
	head.train_back = nil
	spos := s.pos
	svel: [2]f32
	if s.train_direction == 1 {
		switch s.axis {
		case .Up_Down:
			spos.y = -1
			svel = { 0, 1 }
		case .Sideway:
			spos.x = -1
			svel = { 1, 0 }
		}
	} else {
		switch s.axis {
		case .Up_Down:
			spos.y = RAIL_GRID_HEIGHT
			svel = { 0, -1 }
		case .Sideway:
			spos.x = RAIL_GRID_WIDTH
			svel = { -1, 0 }
		}
	}
	head.pos = { f32(spos.x), f32(spos.y) } * RAIL_SIZE
	head.speed = head.train_speed
	head.dir = svel
	
	prev_handle := head_handle
	for _ in 0..<length - 1 {
		tail_handle := alloc_train()
		s.train_active += 1
	
		tail := get_train(tail_handle)
		prev := get_train(prev_handle)

		prev.train_back = tail_handle
		
		tail.type = .Cargo
		tail.train_speed = prev.train_speed
		
		tail.spawner_index = spawner_index
		tail.axis = s.axis
		tail.train_fwd = prev_handle
		tail.train_back = nil
		
		tail.pos = prev.pos - svel * TRAIN_SIZE
		tail.speed = prev.speed
		tail.dir = svel
		
		prev_handle = tail_handle
	}
}

decide_spawn_type :: proc(spawner_index: int) {
	s := &g_mem.train_spawners[spawner_index]
	quota_sum := s.quota_normal + s.quota_fast + s.quota_long
	if quota_sum == 0 {
		return
	}
	
	if s.quota_dir_change > 0 {
		if quota_sum - 1 <= s.quota_dir_change || rand.int_max(5) == 0 {
			s.quota_dir_change -= 1
			s.dir_change_queued = true
		}
	}

	if g_mem.game_state_machine == .Title {
		s.spawn_type = .Normal
		return
	}
	
	r := rand.int_max(quota_sum)
	r -= s.quota_normal
	if r < 0 {
		s.spawn_type = .Normal
		return
	}
	
	r -= s.quota_fast
	if r < 0 {
		s.spawn_type = .Fast
		return
	}
	
	r -= s.quota_long
	if r < 0 {
		s.spawn_type = .Long
		return
	}
}

update_train_spawners :: proc() {
	if g_mem.game_state_machine == .Title {
		for &s, i in g_mem.train_spawners {
			s.timer -= DELTA_TIME
			if s.timer < 0 {
				spawn_train(i, .Head, 3, 1)
				s.timer = s.spawn_time + random_scaler(2)
			}
		}
	} else {
		wave_endable := true
		for &s, i in g_mem.train_spawners {
			// change direction
			if s.dir_change_queued {
				s.timer -= DELTA_TIME
				if s.timer < 2 {
					s.timer = 2
				}
				if s.train_active == 0 {
					s.dir_change_queued = false
					s.train_direction = s.train_direction * -1
				}
				wave_endable = false
				continue
			}

			quota_sum := s.quota_normal + s.quota_fast + s.quota_long
			if quota_sum > 0 || s.train_active > 0 {
				wave_endable = false
			}
			
			// spawn train
			s.timer -= DELTA_TIME
			if s.timer < 0 && quota_sum > 0 {
				switch s.spawn_type {
				case .Normal:
					spawn_train(i, .Head, 3 + (g_mem.current_wave / 15), 1)
					s.quota_normal -= 1
				case .Fast:
					spawn_train(i, .Head, 3 + (g_mem.current_wave / 15), 2)
					s.quota_fast -= 1
				case .Long:
					spawn_train(i, .Head, 7 + (g_mem.current_wave / 15), 0.8)
					s.quota_long -= 1
				}
				decide_spawn_type(i)
				s.timer = s.spawn_time + random_scaler(2)
			}
		}
		if g_mem.train_pool.used > 0 {
			wave_endable = false
		}

		if wave_endable {
			if g_mem.current_wave % 3 == 0 {
				g_mem.current_level += 1
				if g_mem.current_level == len(levels) {
					g_mem.current_level = 0
				}
				g_mem.fade_out = true
				g_mem.fade_out_timer = 1
			} else {
				enter_wave_start()
			}
			g_mem.current_wave += 1
		}
	}
	
}

draw_train_spawners :: proc() {
	for s, i in g_mem.train_spawners {
		if s.dir_change_queued { continue }
		if s.quota_normal == 0 && s.quota_fast == 0 && s.quota_long == 0 { continue }
		if s.timer < 2 {
			phase := math.mod(s.timer, 0.5)
			if phase < 0.25 {
				pos := [2]f32 { f32(s.pos.x), f32(s.pos.y) } * RAIL_SIZE
				pos += s.axis == .Sideway ? { 0, -4 } : { -4, 0 }
				pos_arr := pos + (s.axis == .Sideway ? { 24, 0 } : { 0, 24 })
				angle: f32
				if s.train_direction < 0 {
					switch s.axis {
					case .Up_Down:
						pos.y = LEVER_AREA - 24
						pos_arr.y = pos.y - 24
						angle = 270
					case .Sideway:
						pos.x = RENDER_WIDTH - 24
						pos_arr.x = pos.x - 24
						angle = 180
					}
				} else {
					switch s.axis {
					case .Up_Down:
						angle = 90
					case .Sideway:
						angle = 0
					}
				}

				texture, texture_arr: rl.Texture
				switch s.spawn_type {
				case .Normal:
					texture = g_mem.textures[.Icon_Normal]
					texture_arr = g_mem.textures[.Arrow_Normal]
				case .Fast:
					texture = g_mem.textures[.Icon_Fast]
					texture_arr = g_mem.textures[.Arrow_Fast]
				case .Long:
					texture = g_mem.textures[.Icon_Long]
					texture_arr = g_mem.textures[.Arrow_Long]
				}
				
				rl.DrawTextureV(texture, pos, rl.WHITE)
				
				src := rl.Rectangle { 0, 0, 24, 24 }
				dst := rl.Rectangle { pos_arr.x + 12, pos_arr.y + 12, 24, 24 }
				rl.DrawTexturePro(texture_arr, src, dst, { 12, 12 }, angle, rl.WHITE)
			}
		}
	}
}

is_train_handle_valid :: proc(h: Train_Handle) -> bool {
	if h.index < 0 || h.index >= len(g_mem.train_pool.arr) {
		return false
	}
	if g_mem.train_pool.arr[h.index].generation != h.generation {
		return false
	}
	return true
}

is_train_handle_valid_maybe :: proc(h_maybe: Maybe(Train_Handle)) -> bool {
	h, ok := h_maybe.(Train_Handle)
	if !ok {
		return false
	}
	return is_train_handle_valid(h)
}

assert_train_handle :: proc(h: Train_Handle, loc := #caller_location) {
	if !is_train_handle_valid(h) {
		panic("Train handle invalid", loc)
	}
}

get_train :: proc(h: Train_Handle, loc := #caller_location) -> ^Train {
	assert_train_handle(h, loc)
	return &g_mem.train_pool.arr[h.index]
}

get_train_handle :: proc(index: int) -> Train_Handle {
	return Train_Handle {
		index = index,
		generation = g_mem.train_pool.arr[index].generation,
	}
}

alloc_train :: proc() -> Train_Handle {
	pool := &g_mem.train_pool
	
	index: int
	if pool.used == len(pool.arr) {
		append(&pool.arr, Train {})
		index = len(pool.arr) - 1
	} else {
		index = pool.head
		pool.head = pool.arr[index].next_index
	}

	// save next index and generation
	next_index := pool.arr[index].next_index
	generation := pool.arr[index].generation

	// zero out the train
	pool.arr[index] = {}

	// restore next index and generation
	pool.arr[index].used = true
	pool.arr[index].next_index = next_index
	pool.arr[index].generation = generation
	
	pool.used += 1
	return Train_Handle {
		index = index,
		generation = pool.arr[index].generation,
	}
}

free_train :: proc(h: Train_Handle, loc := #caller_location) {
	assert_train_handle(h, loc)
	pool := &g_mem.train_pool

	t := &pool.arr[h.index]
	g_mem.train_spawners[t.spawner_index].train_active -= 1
	
	t.used = false
	t.generation += 1
	t.next_index = pool.head
	pool.head = h.index
	pool.used -= 1
}

free_all_trains :: proc() {
	for &t, i in g_mem.train_pool.arr {
		if t.used {
			free_train(get_train_handle(i))
		}
	}
}

out_of_screen :: proc(pos: [2]f32) -> bool {
	W :: RAIL_GRID_WIDTH  * RAIL_SIZE
	H :: RAIL_GRID_HEIGHT * RAIL_SIZE
	return pos.x < -TRAIN_SIZE * 2 || pos.x > W + TRAIN_SIZE ||
	       pos.y < -TRAIN_SIZE * 2 || pos.y > H + TRAIN_SIZE
}

explode_train :: proc(i: int) {
	t := &g_mem.train_pool.arr[i]
	for _ in 0..<8 {
		pos := t.pos + TRAIN_SIZE / 2
		pos += random_vector(10)
		vel := random_unit_vector() * 150
		rot := random_angle()
		vel_rot := random_scaler(1000)
		size := 10 + random_scaler(2)
		color := rl.ORANGE
		add_particle(pos, vel, rot, vel_rot, size, color, 0.3)
	}
	g_mem.heart -= 1
	free_train(get_train_handle(i))
}

move_toward :: proc(value, target, amount: f32) -> f32 {
	d := target - value
	if abs(d) < amount {
		return target
	} else {
		return value + math.sign(d) * amount
	}
}

update_trains :: proc() {
	click_consumed: bool
	m := mouse_position()
	
	// no clicking on train if mouse is in lever area
	if m.y > LEVER_AREA {
		click_consumed = true
	}
	
	loop_i: for &t, i in g_mem.train_pool.arr {
		if !t.used { continue }

		// remove invalid references
		if !is_train_handle_valid_maybe(t.train_fwd) {
			t.train_fwd = nil
		}
		if !is_train_handle_valid_maybe(t.train_back) {
			t.train_back = nil
		}

		// do collision with rails
		r := get_rail(t.pos)
		if r != nil {
			axis := get_rail_axis(r.(Rail))
			if axis != t.axis {
				explode_train(i)
				continue
			}
		}
		absdir := [2]f32 { abs(t.dir.x), abs(t.dir.y) }
		r = get_rail(t.pos + absdir * TRAIN_SIZE)
		if r != nil {
			axis := get_rail_axis(r.(Rail))
			if axis != t.axis {
				explode_train(i)
				continue
			}
		}
		
		if !click_consumed && rl.IsMouseButtonPressed(.LEFT) {
			rec_click := rl.Rectangle {
				t.pos.x - TRAIN_CLICK_OFFSET,
				t.pos.y - TRAIN_CLICK_OFFSET,
				TRAIN_CLICK_SIZE,
				TRAIN_CLICK_SIZE,
			}
			if rl.CheckCollisionPointRec(m, rec_click) {
				click_consumed = true
				head := &t
				for is_train_handle_valid_maybe(head.train_fwd) {
					head = get_train(head.train_fwd.(Train_Handle))
				}
				head.stopped = !head.stopped
			}
		}
		
		// collision with other trains
		rec := rl.Rectangle {
			t.pos.x,
			t.pos.y,
			TRAIN_SIZE,
			TRAIN_SIZE,
		}
		loop_j: for &tj, j in g_mem.train_pool.arr {
			if !tj.used { continue }
			if i == j { continue }

			recj := rl.Rectangle {
				tj.pos.x,
				tj.pos.y,
				TRAIN_SIZE,
				TRAIN_SIZE,
			}
			if rl.CheckCollisionRecs(rec, recj) {
				explode_train(i)
				explode_train(j)
				continue loop_i
			}
		}

		// explode lone cargos
		if t.type == .Cargo && t.scored == false {
			if !t.explode {
				if !is_train_handle_valid_maybe(t.train_fwd) {
					t.train_fwd = nil
					t.explode = true
				}
			} else {
				t.explode_timer += DELTA_TIME
				if t.explode_timer > 0.05 {
					explode_train(i)
					continue
				}
			}
		}

		// explode stopped train head
		if t.type != .Cargo && t.stopped {
			t.stop_timer += DELTA_TIME
			if t.stop_timer > 10 {
				explode_train(i)
				continue
			}
		}

		// score trains that reached out side of the screen
		if out_of_screen(t.pos) {
			if t.type != .Cargo {
				back_handle := t.train_back
				for back_handle != nil {
					h := back_handle.(Train_Handle)
					if !is_train_handle_valid(h) { break }

					cargo := get_train(h)
					cargo.scored = true
					back_handle = cargo.train_back
				}
				
				g_mem.score += train_score[t.type] * g_mem.current_wave
				free_train(get_train_handle(i))
				continue
			} else {
				// only scored cargo can get scored
				if t.scored {
					g_mem.score += train_score[t.type] * g_mem.current_wave
					free_train(get_train_handle(i))
					continue
				}
			}
		}

		// move train
		SPEED_CHANGE :: DELTA_TIME * 1200
		if t.type == .Cargo {
			if is_train_handle_valid_maybe(t.train_fwd) {
				fwd := get_train(t.train_fwd.(Train_Handle))
				t.speed = fwd.speed
				t.pos_new = fwd.pos - t.dir * TRAIN_OFFSET
			} else {
				target_speed: f32 = t.scored ? t.train_speed : 0
				t.speed = move_toward(t.speed, target_speed, SPEED_CHANGE)
	
				t.pos_new = t.pos + t.dir * t.speed * DELTA_TIME
			}
		} else {
			target_speed: f32 = t.stopped ? 0 : t.train_speed
			t.speed = move_toward(t.speed, target_speed, SPEED_CHANGE)
	
			t.pos_new = t.pos + t.dir * t.speed * DELTA_TIME
		}
	}

	for &t, i in g_mem.train_pool.arr {
		if !t.used { continue }
		t.pos = t.pos_new
	}
}

draw_trains :: proc() {
	for t, i in g_mem.train_pool.arr {
		if !t.used { continue }
		texture: rl.Texture
		switch t.type {
		case .Head:
			texture = g_mem.textures[.Train]
		case .Cargo:
			texture = g_mem.textures[.Cargo]
		}
		angle: f32
		switch {
		case t.dir == {  1,  0 }: angle = 0
		case t.dir == {  0,  1 }: angle = 90
		case t.dir == { -1,  0 }: angle = 180
		case t.dir == {  0, -1 }: angle = 270
		}
		w := f32(texture.width)
		h := f32(texture.height)
		hw := w / 2
		hh := h / 2
		src := rl.Rectangle { 0, 0, w, h, }
		dst := rl.Rectangle { // draw it on center of the rail
			t.pos.x + TRAIN_SIZE / 2,
			t.pos.y + TRAIN_SIZE / 2,
			w,
			h,
		}
		rl.DrawTexturePro(texture, src, dst, { hw, hh }, angle, rl.WHITE)
		if t.stopped && t.stop_timer > 7.0 {
			phase := math.mod(t.stop_timer, 0.5)
			if phase < 0.25 {
				rl.DrawTextureV(g_mem.textures[.Danger], t.pos, rl.WHITE)
			}
		}
	}
}

add_particle :: proc(
	pos: [2]f32,
	vel: [2]f32,
	rot: f32,
	vel_rot: f32,
	size: f32,
	color: rl.Color,
	lifetime: f32,
) {
	append(&g_mem.particles, Particle {
		pos = pos,
		vel = vel,
		rot = rot,
		vel_rot = vel_rot,
		size = size,
		color = color,
		lifetime = lifetime,
	})
}

update_particles :: proc() {
	#reverse for &p, i in g_mem.particles {
		p.time_elapsed += DELTA_TIME
		if p.time_elapsed > p.lifetime {
			unordered_remove(&g_mem.particles, i)
		}

		p.pos += p.vel*DELTA_TIME
		p.rot += p.vel_rot*DELTA_TIME
	}
}

draw_particles :: proc() {
	for p in g_mem.particles {
		t := 1.0 - (p.time_elapsed / p.lifetime)
		size := p.size*(t*0.5 + 0.5)
		rec := rl.Rectangle {
			p.pos.x,
			p.pos.y,
			size,
			size,
		}
		c := p.color
		c.a = u8(f32(c.a)*t)
		rl.DrawRectanglePro(rec, size / 2, p.rot, c)
	}
}

