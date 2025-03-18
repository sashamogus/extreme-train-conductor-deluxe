package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Game_State_Machine :: union {
	Game_State_Title,
	Game_State_How_To_Play,
	Game_State_Level_Start,
	Game_State_Wave_Start,
	Game_State_Game,
	Game_State_Gameover,
}

Game_State_Title :: struct {
	fade_in: bool,
	fade_in_timer: f32,
	fade_to_level_start: bool,
	fade_out_timer: f32,
}
Game_State_How_To_Play :: struct {
}
Game_State_Level_Start :: struct {
	fade_in: bool,
	fade_in_timer: f32,
}
Game_State_Wave_Start :: struct {
	wave_countdown: f32,
}
Game_State_Game :: struct {
	fade_to_level_start: bool,
	fade_out_timer: f32,
}
Game_State_Gameover :: struct {
	fade_to_title: bool,
	fade_out_timer: f32,
}

im_button :: proc(text: cstring, pos: [2]i32, font_size: i32) -> bool {
	text_size := rl.MeasureText(text, font_size)
	ptext_size := text_size + 20
	pfont_size := font_size + 20
	rect := rl.Rectangle {
		f32(pos.x - ptext_size / 2),
		f32(pos.y - pfont_size / 2) + 10,
		f32(ptext_size),
		f32(pfont_size),
	}
	
	color := rl.GRAY
	m := mouse_position()
	ret: bool
	if rl.CheckCollisionPointRec(m, rect) {
		color = rl.ColorBrightness(color, -0.5)
		if rl.IsMouseButtonPressed(.LEFT) {
			ret = true
		}
		if rl.IsMouseButtonDown(.LEFT) {
			color = rl.ColorBrightness(color, -0.5)
		}
	}
	rl.DrawRectangleRec(rect, color)
	rl.DrawRectangleLinesEx(rect, 1, rl.BLACK)
	rl.DrawText(text, pos.x - text_size / 2, pos.y, font_size, rl.WHITE)
	return ret
}

next_game_state: Maybe(Game_State_Machine)
update_game_state :: proc() {
	next_game_state = nil
	
	switch &state in g_mem.game_state_machine {
	case Game_State_Title:
		update_title(&state)
	case Game_State_How_To_Play:
		update_how_to_play(&state)
	case Game_State_Level_Start:
		update_level_start(&state)
	case Game_State_Wave_Start:
		update_wave_start(&state)
	case Game_State_Game:
		update_game(&state)
	case Game_State_Gameover:
		update_gameover(&state)
	}

	if next_game_state != nil {
		g_mem.game_state_machine = next_game_state.(Game_State_Machine)
	}
}

draw_hud :: proc() {
	rl.DrawText(fmt.ctprint("Highscore: ", g_mem.highscore), 0, LEVER_AREA - 40, 20, rl.WHITE)
	rl.DrawText(fmt.ctprint("Score: ", g_mem.score), 0, LEVER_AREA - 20, 20, rl.WHITE)
	rl.DrawText(fmt.ctprint("Heart: ", g_mem.heart), 0, LEVER_AREA, 20, rl.WHITE)
	rl.DrawText(fmt.ctprint("Wave: ", g_mem.current_wave), 0, LEVER_AREA + 20, 20, rl.WHITE)
}

draw_fade_in :: proc(t: f32, on: bool) {
	if !on { return }
	c := rl.BLACK
	c.a = u8(math.saturate(t)*255)
	rl.DrawRectangle(0, 0, RENDER_WIDTH, RENDER_HEIGHT, c)
}

draw_fade_out :: proc(t: f32, on: bool) {
	if !on { return }
	c := rl.BLACK
	c.a = u8(math.saturate(1.0 - t)*255)
	rl.DrawRectangle(0, 0, RENDER_WIDTH, RENDER_HEIGHT, c)
}

enter_title :: proc(fade_in: bool) {
	next_game_state = Game_State_Title {
		fade_in = fade_in,
		fade_in_timer = 1,
	}
	load_level(title_level)
	wave_start()
}

update_title :: proc(state: ^Game_State_Title) {
	update_train_spawners()
	update_trains()
	update_particles()

	if state.fade_in {
		state.fade_in_timer -= DELTA_TIME
		if state.fade_in_timer < 0 {
			state.fade_in = false
		}
	} else if state.fade_to_level_start {
		state.fade_out_timer -= DELTA_TIME
		if state.fade_out_timer < 0 {
			game_start()
			enter_level_start()
		}
	}
	g_mem.score = 0

	draw_text_centered("Extreme Train Conductor Deluxe!!!", RENDER_WIDTH / 2, 50, 30, rl.WHITE)
	draw_rails()
	draw_trains()
	draw_particles()

	if im_button("Game Start", { RENDER_WIDTH / 2, RENDER_HEIGHT - 150 }, 20) {
		if !state.fade_to_level_start && !state.fade_in {
			state.fade_to_level_start = true
			state.fade_out_timer = 1
		}
	}
	if im_button("How To Play", { RENDER_WIDTH / 2, RENDER_HEIGHT - 100 }, 20) {
		if !state.fade_to_level_start && !state.fade_in {
			enter_how_to_play()
		}
	}

	draw_fade_in(state.fade_in_timer, state.fade_in)
	draw_fade_out(state.fade_out_timer, state.fade_to_level_start)
}

enter_how_to_play :: proc() {
	next_game_state = Game_State_How_To_Play {}
}

update_how_to_play :: proc(state: ^Game_State_How_To_Play) {
	y: i32 = 100
	draw_text_centered("Click on levers to switch the rails", RENDER_WIDTH / 2, y, 20, rl.WHITE)
	y += 30
	
	src := rl.Rectangle {
		0,
		0,
		LEVER_SIZE,
		LEVER_SIZE,
	}
	lever_pos := [2]f32 { (RENDER_WIDTH / 2) - 100, f32(y) }
	rl.DrawTextureRec(g_mem.textures[.Lever], src, lever_pos, rl.WHITE)
	tex_ud := g_mem.textures[.Rail_Up_Down]
	tex_sw := g_mem.textures[.Rail_Sideway]
	tex_st := g_mem.textures[.Rail_Switch_SW]
	rail_x: i32 = (RENDER_WIDTH / 2) + 20
	draw_rail(tex_ud, rail_x, y, rl.WHITE)
	draw_rail(tex_st, rail_x, y + RAIL_SIZE, rl.BLUE)
	draw_rail(tex_ud, rail_x, y + RAIL_SIZE * 2, rl.WHITE)
	draw_rail(tex_sw, rail_x - RAIL_SIZE, y + RAIL_SIZE, rl.WHITE)
	draw_rail(tex_sw, rail_x + RAIL_SIZE, y + RAIL_SIZE, rl.WHITE)
	y += 50

	draw_text_centered("Click on trains to stop trains", RENDER_WIDTH / 2, y, 20, rl.WHITE)
	y += 20
	draw_text_centered("Click again to start it", RENDER_WIDTH / 2, y, 20, rl.WHITE)
	y += 20

	tex_train := g_mem.textures[.Train]
	tex_cargo := g_mem.textures[.Cargo]
	train_x: i32 = (RENDER_WIDTH / 2) + 20
	train_y: i32 = y + 15
	rl.DrawTexture(tex_train, train_x, train_y, rl.WHITE)
	for i in 1..<i32(6) {
		rl.DrawTexture(tex_cargo, train_x - TRAIN_OFFSET * i, train_y, rl.WHITE)
	}
	y += 50

	draw_text_centered("And make sure nothing explode!", RENDER_WIDTH / 2, y, 20, rl.WHITE)
	y += 20
	
	if im_button("Back", { RENDER_WIDTH / 2, y + 30 }, 20) {
		enter_title(false)
	}
}

enter_level_start :: proc() {
	next_game_state = Game_State_Level_Start {
		fade_in = true,
		fade_in_timer = 1,
	}
}

update_level_start :: proc(state: ^Game_State_Level_Start) {
	update_levers()
	update_rails()
	update_particles()
	
	if state.fade_in {
		state.fade_in_timer -= DELTA_TIME
		if state.fade_in_timer < 0 {
			state.fade_in = false
		}
	}
	draw_rails()
	draw_levers()
	draw_particles()
	draw_hud()
	if im_button("Start", { RENDER_WIDTH / 2, 250}, 20) {
		if !state.fade_in {
			enter_wave_start()
		}
	}
	
	draw_fade_in(state.fade_in_timer, state.fade_in)
}

enter_wave_start :: proc() {
	next_game_state = Game_State_Wave_Start {
		wave_countdown = 3,
	}
}
 
update_wave_start :: proc(state: ^Game_State_Wave_Start) {
	update_levers()
	update_rails()
	update_particles()
	
	state.wave_countdown -= DELTA_TIME
	if state.wave_countdown < 0 {
		enter_game()
	}
	
	draw_rails()
	draw_levers()
	draw_particles()
	draw_hud()
	x: i32 = (RENDER_WIDTH  / 2)
	y: i32 = (RENDER_HEIGHT / 2) - 100
	text := fmt.ctprintf("Wave %v starts in ...", g_mem.current_wave)
	draw_text_centered(text, x, y, 20, rl.WHITE)
	text = fmt.ctprint(math.ceil(max(state.wave_countdown, 1)))
	rl.DrawText(text, x - 10, y + 50, 50, rl.WHITE)
}

enter_game :: proc() {
	next_game_state = Game_State_Game {}
	wave_start()
}

update_game :: proc(state: ^Game_State_Game) {
	if state.fade_to_level_start {
		state.fade_out_timer -= DELTA_TIME
		if state.fade_out_timer < 0 {
			load_level(levels[g_mem.current_level])
			enter_level_start()
		}
	} else {
		update_levers()
		update_rails()
		update_train_spawners()
		update_trains()
		update_particles()

		for m in game_messages {
			switch m {
			case .Wave_End:
				if g_mem.current_wave % 3 == 0 {
					g_mem.current_level += 1
					if g_mem.current_level == len(levels) {
						g_mem.current_level = 0
					}
					state.fade_to_level_start = true
					state.fade_out_timer = 1
				} else {
					enter_wave_start()
				}
				g_mem.current_wave += 1
			}
		}
		
		if g_mem.heart < 0 {
			free_all_trains()
			enter_gameover()
		}
	}
	
	draw_rails()
	draw_train_spawners()
	draw_trains()
	draw_levers()
	draw_particles()
	draw_hud()
	
	draw_fade_out(state.fade_out_timer, state.fade_to_level_start)
}

enter_gameover :: proc() {
	next_game_state = Game_State_Gameover {}
}

update_gameover :: proc(state: ^Game_State_Gameover) {
	update_levers()
	update_rails()
	update_particles()
	
	if state.fade_to_title {
		state.fade_out_timer -= DELTA_TIME
		if state.fade_out_timer < 0 {
			enter_title(true)
		}
	}

	
	draw_rails()
	draw_train_spawners()
	draw_trains()
	draw_levers()
	draw_particles()
	draw_hud()
	
	x: i32 = (RENDER_WIDTH  / 2)
	y: i32 = (RENDER_HEIGHT / 2) - 100
	draw_text_centered("Gameover!!", x, y, 20, rl.WHITE)
	if im_button("Go Back To Title", { RENDER_WIDTH / 2, 250}, 20) {
		if !state.fade_to_title {
			state.fade_to_title = true
			state.fade_out_timer = 1
		}
	}
	
	draw_fade_out(state.fade_out_timer, state.fade_to_title)
}
