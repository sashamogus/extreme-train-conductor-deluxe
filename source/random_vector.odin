package game

import "core:math"
import "core:math/rand"

random_angle :: proc() -> f32 {
	return rand.float32_range(-math.PI, math.PI)
}

random_unit_vector :: proc() -> [2]f32 {
	angle := random_angle()
	return { math.cos(angle), math.sin(angle), }
}

random_scaler :: proc(range: f32) -> f32 {
	return rand.float32_range(-range, range),
}

random_vector :: proc(range: [2]f32) -> [2]f32 {
	return {
		rand.float32_range(-range.x, range.x),
		rand.float32_range(-range.y, range.y),
	}
}
