package game

Level :: struct {
	rail_grid: Rail_Grid,
	lever_num: int,
	train_spawners: []Train_Spawner,
}

NO :: Rail { type = .None }
UD :: Rail { type = .Up_Down }
SW :: Rail { type = .Sideway }
S0 :: Rail { type = .Switch, switch_index = 0 }
S1 :: Rail { type = .Switch, switch_index = 1 }
S2 :: Rail { type = .Switch, switch_index = 2 }
S3 :: Rail { type = .Switch, switch_index = 3 }

@(rodata)
title_level := Level {
	lever_num = 1,
	rail_grid = {
	//    ==========================================================================      ==========================================================================
	//    00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 00
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 01
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 02
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 03
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 04
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 05
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 06
		{ SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, }, // 07
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 08
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 09
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 10
		{ SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, }, // 11
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 12
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 13
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 14
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 15
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 16
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 17
		{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 18
	},
	train_spawners = {
		Train_Spawner { pos = {  0,  7 }, axis = .Sideway },
		Train_Spawner { pos = {  0, 11 }, axis = .Sideway },
	}
}

@(rodata)
levels := [?]Level {
	Level {
		lever_num = 1,
		rail_grid = {
		//    ==========================================================================      ==========================================================================
		//    00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 00
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 01
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 02
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 03
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 04
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 05
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 06
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 07
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 08
			{ SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, S0, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, }, // 09
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 10
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 11
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 12
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 13
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 14
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 15
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 16
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 17
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 18
		},
		train_spawners = {
			Train_Spawner { pos = { 19,  0 }, axis = .Up_Down },
			Train_Spawner { pos = {  0,  9 }, axis = .Sideway },
		}
	},
	Level {
		lever_num = 2,
		rail_grid = {
		//    ==========================================================================      ==========================================================================
		//    00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
		//    ================================================--                                                      --================================================
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 00
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 01
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 02
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 03
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 04
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 05
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 06
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 07
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 08
			{ SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, S0, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, S1, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, }, // 09
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 10
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 11
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 12
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 13
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 14
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 15
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 16
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 17
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 18
		},
		train_spawners = {
			Train_Spawner { pos = { 12,  0 }, axis = .Up_Down },
			Train_Spawner { pos = { 26,  0 }, axis = .Up_Down },
			Train_Spawner { pos = {  0,  9 }, axis = .Sideway },
		}
	},
	Level {
		lever_num = 4,
		rail_grid = {
		//    ==========================================================================      ==========================================================================
		//    00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
		//    ================================================--                                                      --================================================
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 00
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 01
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 02
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 03
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 04
			{ SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, S0, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, S1, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, }, // 05
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 06
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 07
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 08
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 09
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 10
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 11
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 12
			{ SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, S2, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, S3, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, SW, }, // 13
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 14
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 15
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 16
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 17
			{ NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, UD, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, }, // 18
		},
		train_spawners = {
			Train_Spawner { pos = { 12,  0 }, axis = .Up_Down },
			Train_Spawner { pos = { 26,  0 }, axis = .Up_Down },
			Train_Spawner { pos = {  0,  5 }, axis = .Sideway },
			Train_Spawner { pos = {  0,  13 }, axis = .Sideway },
		}
	},
}
